param (
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-RequiredEnvPrefix.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$env_prefix = Get-RequiredEnvPrefix
$apps_config = Get-AppsConfig
$infra_global_config = Get-InfraConfig -GlobalConfig
$infra_config = Get-InfraConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $env_prefix) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $env_prefix) | Out-Null
}
Write-Host "[INFO] Running in '$env_prefix' terraform workspace" -ForegroundColor Green

$cache_yaml = Get-Content -Path ".cache" | ConvertFrom-Yaml
terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var="project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var="global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
  -var="environment_prefix=$env_prefix" `
  -var="backend_image_name=${cache_yaml.backend_image_name}" `
  -var="frontend_image_name=${cache_yaml.frontend_image_name}" `
  -var="ingress_address_name=$($infra_config.GCP_INGRESS_ADDRESS_RES_NAME)" `
  -var="redis_address_name=$($infra_config.GCP_REDIS_ADDRESS_RES_NAME)" `
  -var="domain_name=$($infra_config.VM_BASED_DOMAIN_NAME)" `
  -var="sql_server_db_username=$($apps_config.SQLSERVER_USERNAME)" `
  -var="sql_server_db_password=$($apps_config.SQLSERVER_PASSWORD)" `
  -var="redis_db_password=$($apps_config.REDIS_PASSWORD)" `
  -var="ESZOP_AZURE_EVENTBUS_CONN_STR=$($apps_config.ESZOP_AZURE_EVENTBUS_CONN_STR)" `
  -var="ESZOP_AZURE_STORAGE_CONN_STR=$($apps_config.ESZOP_AZURE_STORAGE_CONN_STR)"