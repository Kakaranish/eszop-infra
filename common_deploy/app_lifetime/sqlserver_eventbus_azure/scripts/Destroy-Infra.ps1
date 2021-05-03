param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [string] $BackupSuffix,
  [switch] $UsePreviousBackupSuffix,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Update-InfraConfigOutput.psm1" -Force

# ------------------------------------------------------------------------------

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"

if (-not($UsePreviousBackupSuffix.IsPresent) -and -not($BackupSuffix)) {
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

if (-not($UsePreviousBackupSuffix.IsPresent) -and -not($BackupSuffix)) {
  $apply_command = @"
  terraform ``
    -chdir="$tf_dir" ``
    destroy ``
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" ``
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" ``
    -var="environment=$CloudEnv" ``
    -var="allowed_ip=$my_ip"
"@
}
else {
  if ($BackupSuffix) {
    $backup_suffix = $BackupSuffix
  }
  else {
    $cache_path = "$PSScriptRoot\output\${CloudEnv}_cache.yaml"
    if (-not(Test-Path $cache_path) ) {
      Write-Error "Cannot read cached backup suffix" -ErrorAction Stop
    }

    $backup_suffix = (Get-Content $cache_path | ConvertFrom-Yaml).LastBackupSuffix
    if (-not($backup_suffix)) {
      Write-Error "Cannot read cached backup suffix" -ErrorAction Stop
    }
  }

  $apply_command = @"
  terraform ``
    -chdir="$tf_dir" ``
    destroy ``
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
    -var="sql_sa_login=$($apps_config.SQLSERVER_USERNAME)" ``
    -var="sql_sa_password=$($apps_config.SQLSERVER_PASSWORD)" ``
    -var="environment=$CloudEnv" ``
    -var="allowed_ip=$my_ip" ``
    -var="global_storage_name=$($infra_global_config.AZ_STORAGE_NAME)" ``
    -var="import_suffix=${backup_suffix}"
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

$infra_output = @{"AZURE_EVENTBUS_CONN_STR" = "NEEDS_TO_BE_GENERATED" }
Update-InfraConfigOutput `
  -CloudEnv $CloudEnv `
  -Entries $infra_output

# ---  Cleanup  ----------------------------------------------------------------

Remove-Item -Path "$PSScriptRoot\..\main.tf", "$PSScriptRoot\..\variables.tf" -Force -ErrorAction SilentlyContinue