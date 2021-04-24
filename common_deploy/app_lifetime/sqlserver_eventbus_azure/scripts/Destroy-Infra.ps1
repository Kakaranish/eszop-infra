param(
  [string] $BackupSuffix,
  [switch] $WithImport,
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-RequiredEnvPrefix.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Update-AppsConfigValue.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$env_prefix = Get-RequiredEnvPrefix
$apps_config = Get-AppsConfig
$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

if (-not($WithImport.IsPresent) -and -not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination "$PSScriptRoot\.."

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" `
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" `
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" `
    -var="environment=${env_prefix}" `
    -var="allowed_ip=$my_ip" `

}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination "$PSScriptRoot\.."

  $backup_suffix = if ($BackupSuffix) { $BackupSuffix } else { Get-Content ".cache" }

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" `
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" `
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" `
    -var="environment=${env_prefix}" `
    -var="allowed_ip=$my_ip" `
    -var="backups_container_uri=$($infra_global_config.AZ_BACKUPS_CONTAINER_URI)" `
    -var="import_suffix=${backup_suffix}" `
}

# ---  Update AppsConfig  ------------------------------------------------------

(Update-AppsConfigValue `
  -Field "ESZOP_AZURE_EVENTBUS_CONN_STR" `
  -Value "[PROVIDE VALUE]") | Out-Null

# ---  Cleanup  ----------------------------------------------------------------

Remove-Item -Path "$PSScriptRoot\..\main.tf", "$PSScriptRoot\..\variables.tf" -Force -ErrorAction SilentlyContinue