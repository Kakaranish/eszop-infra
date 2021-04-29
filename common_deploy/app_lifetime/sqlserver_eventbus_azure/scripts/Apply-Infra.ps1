param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [string] $BackupSuffix,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Update-AppsConfigValue.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv
$infra_config = Get-InfraConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"

if (-not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination $tf_dir
}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination $tf_dir
}

terraform -chdir="$tf_dir" init

(terraform -chdir="$tf_dir" workspace select $CloudEnv) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $CloudEnv) | Out-Null
}
Write-Host "[INFO] Running in '$CloudEnv' terraform workspace" -ForegroundColor Green

$my_ip = (Invoke-WebRequest ipinfo.io/ip).Content.Trim()

if (-not($BackupSuffix)) {
  $apply_command = @"
  terraform ``
    -chdir="$tf_dir" ``
    apply ``
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" ``
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" ``
    -var="environment=$CloudEnv" ``
    -var="allowed_ip=${my_ip}"
"@
}
else {
  $apply_command = @"
  terraform ``
    -chdir="$tf_dir" ``
    apply ``
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" ``
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" ``
    -var="environment=$CloudEnv" ``
    -var="allowed_ip=$my_ip" ``
    -var="backups_container_uri=$($infra_global_config.AZ_BACKUPS_CONTAINER_URI)" ``
    -var="import_suffix=$BackupSuffix"
"@
}

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command
if ($LASTEXITCODE -ne 0) {
  Exit
}

# ---  Update AppsConfig  ------------------------------------------------------

$event_bus_conn_str = az servicebus namespace authorization-rule keys list `
  --resource-group $infra_config.AZ_RESOURCE_GROUP `
  --namespace-name "$($infra_config.AZ_RESOURCE_GROUP)-event-bus" `
  --name RootManageSharedAccessKey `
  --query primaryConnectionString `
  -o tsv

(Update-AppsConfigValue `
    -CloudEnv $CloudEnv `
    -Field "ESZOP_AZURE_EVENTBUS_CONN_STR" `
    -Value $event_bus_conn_str) | Out-Null

$output_filename = "cache.yaml"
if (-not(Test-Path -Path "$PSScriptRoot\output")) {
  New-Item -ItemType Directory "output" | Out-Null
}
New-Item -ItemType File -Path "$PSScriptRoot\output\${output_filename}" -Force | Out-Null
$cache_info = @{ 
  "LastBackupSuffix"         = $BackupSuffix;
  "EventBusConnectionString" = $event_bus_conn_str
}
$cache_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\output\${output_filename}" -NoNewline

# ---  Cleanup  ----------------------------------------------------------------

Remove-Item -Path "$PSScriptRoot\..\main.tf", "$PSScriptRoot\..\variables.tf" -Force -ErrorAction SilentlyContinue