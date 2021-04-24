param(
  [string] $BackupSuffix,
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-RequiredEnvPrefix.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Update-AppsConfigValue.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$my_ip = (Invoke-WebRequest ipinfo.io/ip).Content.Trim()
$env_prefix = Get-RequiredEnvPrefix
$apps_config = Get-AppsConfig
$infra_config = Get-InfraConfig
$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

if (-not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination $tf_dir

  terraform.exe `
    -chdir="$tf_dir" `
    apply `
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" `
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" `
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" `
    -var="environment=${env_prefix}" `
    -var="allowed_ip=$my_ip"
}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination $tf_dir

  terraform.exe `
    -chdir="$tf_dir" `
    apply `
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" `
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" `
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" `
    -var="environment=${env_prefix}" `
    -var="allowed_ip=$my_ip" `
    -var="backups_container_uri=$($infra_global_config.AZ_BACKUPS_CONTAINER_URI)" `
    -var="import_suffix=$BackupSuffix"

  New-Item -ItemType File -Name ".cache" -Force | Out-Null
  Set-Content ".cache" $BackupSuffix
}

# ---  Update AppsConfig  ------------------------------------------------------

$event_bus_conn_str = az servicebus namespace authorization-rule keys list `
  --resource-group $infra_config.AZ_RESOURCE_GROUP `
  --namespace-name "$($infra_config.AZ_RESOURCE_PREFIX)-event-bus" `
  --name RootManageSharedAccessKey `
  --query primaryConnectionString `
  -o tsv

(Update-AppsConfigValue `
  -Field "ESZOP_AZURE_EVENTBUS_CONN_STR" `
  -Value $event_bus_conn_str) | Out-Null

# ---  Cleanup  ----------------------------------------------------------------

Remove-Item -Path "$PSScriptRoot\..\main.tf", "$PSScriptRoot\..\variables.tf" -Force