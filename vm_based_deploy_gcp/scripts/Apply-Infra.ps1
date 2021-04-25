param(
  [string] $BackendImageName,
  [string] $FrontendImageName,
  [switch] $Init,
  [switch] $UsePreviousParams
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

if ($UsePreviousParams.IsPresent) {
  $cache_yaml = Get-Content -Path ".cache" | ConvertFrom-Yaml
  $BackendImageName = $cache_yaml.backend_image_name
  $FrontendImageName = $cache_yaml.frontend_image_name
}

if (-not($BackendImageName)) {
  Write-Error "BackendImageName cannot be empty" -ErrorAction Stop
}
if (-not($FrontendImageName)) {
  Write-Error "FrontendImageName cannot be empty" -ErrorAction Stop
}

Write-Host "[INFO] Running with params:" -ForegroundColor Green
Write-Host "[INFO] Environment: $env:ASPNETCORE_ENVIRONMENT" -ForegroundColor Green
Write-Host "[INFO] BackendImageName: $BackendImageName" -ForegroundColor Green
Write-Host "[INFO] FrontendImageName: $FrontendImageName" -ForegroundColor Green

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $env_prefix) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $env_prefix) | Out-Null
}
Write-Host "[INFO] Running in '$env_prefix' terraform workspace" -ForegroundColor Green

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var="project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var="global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
  -var="environment_prefix=$env_prefix" `
  -var="backend_image_name=$BackendImageName" `
  -var="frontend_image_name=$FrontendImageName" `
  -var="ingress_address_name=$($infra_config.GCP_INGRESS_ADDRESS_RES_NAME)" `
  -var="redis_address_name=$($infra_config.GCP_REDIS_ADDRESS_RES_NAME)" `
  -var="domain_name=$($infra_config.VM_BASED_DOMAIN_NAME)" `
  -var="sql_server_db_username=$($apps_config.SQLSERVER_USERNAME)" `
  -var="sql_server_db_password=$($apps_config.SQLSERVER_PASSWORD)" `
  -var="redis_db_password=$($apps_config.REDIS_PASSWORD)" `
  -var="ESZOP_AZURE_EVENTBUS_CONN_STR=$($apps_config.ESZOP_AZURE_EVENTBUS_CONN_STR)" `
  -var="ESZOP_AZURE_STORAGE_CONN_STR=$($apps_config.ESZOP_AZURE_STORAGE_CONN_STR)" `

$cache_content = @{
  backend_image_name  = $BackendImageName;
  frontend_image_name = $FrontendImageName
}
New-Item -ItemType File -Name ".cache" -Force | Out-Null
$cache_content | ConvertTo-Yaml | Set-Content ".cache" -NoNewline