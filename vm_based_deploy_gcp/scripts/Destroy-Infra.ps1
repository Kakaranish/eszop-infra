param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "$PSScriptRoot\Config.psm1" -Force
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfigOutput.psm1" -Force

# ------------------------------------------------------------------------------

if (-not $gateway_image_name -or -not $offers_image_name -or -not $identity_image_name `
    -or -not $carts_image_name -or -not $orders_image_name -or -not $notification_image_name `
    -or -not $frontend_image_name) {
  Write-Host "[ERROR] Fill Config.psm1 before applying infra" -ForegroundColor Red
  Exit
}

$env_prefix_map = @{
  "dev"     = "Staging";
  "staging" = "Staging";
  "prod"    = "Production"
}

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"
$infra_config = Get-InfraConfig -CloudEnv $CloudEnv
$infra_output = Get-InfraConfigOutput -CloudEnv $CloudEnv

if ($Init.IsPresent) {
  terraform -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $CloudEnv) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $CloudEnv) | Out-Null
}
Write-Host "[INFO] Running in '$CloudEnv' terraform workspace" -ForegroundColor Green

terraform `
  -chdir="$tf_dir" `
  destroy `
  -var="project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var="global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="environment=$($env_prefix_map[$CloudEnv])" `
  -var="environment_prefix=$CloudEnv" `
  -var="gateway_image_name=${gateway_image_name}" `
  -var="offers_image_name=${offers_image_name}" `
  -var="identity_image_name=${identity_image_name}" `
  -var="carts_image_name=${carts_image_name}" `
  -var="orders_image_name=${orders_image_name}" `
  -var="notification_image_name=${notification_image_name}" `
  -var="frontend_image_name=${frontend_image_name}" `
  -var="redis_address_ip=$($infra_output.REDIS_ADDRESS)" `
  -var="domain_name=$($infra_config.VM_BASED_DOMAIN_NAME)" `
  -var="sql_server_db_username=$($apps_config.SQLSERVER_USERNAME)" `
  -var="sql_server_db_password=$($apps_config.SQLSERVER_PASSWORD)" `
  -var="redis_db_password=$($apps_config.REDIS_PASSWORD)" `
  -var="ESZOP_AZURE_EVENTBUS_CONN_STR=$($infra_output.AZURE_EVENTBUS_CONN_STR)" `
  -var="ESZOP_AZURE_STORAGE_CONN_STR=$($infra_output.AZURE_STORAGE_CONN_STR)"