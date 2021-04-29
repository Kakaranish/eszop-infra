param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [string] $BackendImageName,
  [string] $FrontendImageName,
  [switch] $Init,
  [switch] $UsePreviousParams
)

$repo_root = "$PSScriptRoot\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$env_prefix_map = @{
  "dev"     = "Staging";
  "staging" = "Staging";
  "prod"    = "Production"
}

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"
$infra_config = Get-InfraConfig -CloudEnv $CloudEnv

if ($UsePreviousParams.IsPresent) {
  $cache_yaml = Get-Content -Path "$PSScriptRoot\output\${CloudEnv}_cache.yaml" | ConvertFrom-Yaml
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
Write-Host "[INFO] Environment: $CloudEnv" -ForegroundColor Green
Write-Host "[INFO] BackendImageName: $BackendImageName" -ForegroundColor Green
Write-Host "[INFO] FrontendImageName: $FrontendImageName" -ForegroundColor Green

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
  apply `
  -var="project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var="global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="environment=$($env_prefix_map[$CloudEnv])" `
  -var="environment_prefix=$CloudEnv" `
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
$cache_content | ConvertTo-Yaml | Set-Content "$PSScriptRoot\output\${CloudEnv}_cache.yaml" -NoNewline