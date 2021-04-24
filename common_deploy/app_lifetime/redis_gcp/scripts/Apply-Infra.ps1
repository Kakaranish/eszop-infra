param(
  [switch] $Init,
  [string] $ImageName
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-RequiredEnvPrefix.psm1" -Force -Scope Local
Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "$PSScriptRoot\Config.psm1" -Force

# ------------------------------------------------------------------------------

$env_prefix = Get-RequiredEnvPrefix
$apps_config = Get-AppsConfig
$infra_config = Get-InfraConfig
$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $env_prefix) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $env_prefix) | Out-Null
}
Write-Host "[INFO] Running in '$env_prefix' terraform workspace" -ForegroundColor Green

$image_name_to_apply = if ($ImageName) { $ImageName } else { $default_image_name }

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var "project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var "global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="redis_password=$($apps_config.REDIS_PASSWORD)" `
  -var="environment=${env_prefix}" `
  -var="image_name=${image_name_to_apply}" `
  -var="redis_address_res_name=$($infra_config.GCP_REDIS_ADDRESS_RES_NAME)"

if ($LASTEXITCODE -eq 0) {
  $cache_info = @{"ImageName" = $image_name_to_apply }
  New-Item -ItemType File -Path "$PSScriptRoot\.cache" -Force | Out-Null
  $cache_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\.cache" -NoNewline
}