param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [string] $ImageName,
  [switch] $UsePreviousImageName,
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Update-InfraConfigOutput.psm1" -Force
Import-Module "$PSScriptRoot\Config.psm1" -Force # Helper config

# ------------------------------------------------------------------------------

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv
$infra_config = Get-InfraConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"

if ($Init) {
  terraform -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $CloudEnv) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $CloudEnv) | Out-Null
}
Write-Host "[INFO] Running in '$CloudEnv' terraform workspace" -ForegroundColor Green

if ($UsePreviousImageName.IsPresent) {
  $cache_yaml = Get-Content -Path "$PSScriptRoot\output\${CloudEnv}_cache.yaml" | ConvertFrom-Yaml
  $image_name_to_apply = $cache_yaml.ImageName
}
else {
  $image_name_to_apply = if ($ImageName) { $ImageName } else { $default_image_name }
}

terraform `
  -chdir="$tf_dir" `
  destroy `
  -var "project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var "global_project_id=$($infra_global_config.GCP_PROJECT_ID)" `
  -var="redis_password=$($apps_config.REDIS_PASSWORD)" `
  -var="env_prefix=$CloudEnv" `
  -var="image_name=${image_name_to_apply}"

if ($LASTEXITCODE -eq 0) {
  $infra_output = @{"REDIS_ADDRESS" = "NEEDS_TO_BE_GENERATED" }
  Update-InfraConfigOutput `
    -CloudEnv $CloudEnv `
    -Entries $infra_output
}