param(
  [string] $ImageName
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\GcpConfig.psm1" -Force
Import-Module "${repo_root}\AppsConfig.psm1" -Force
Import-Module $PSScriptRoot\Config.psm1 -Force

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

$image_name_to_apply = if ($ImageName) { $ImageName } else { $default_image_name }

terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var "project_id=$GCP_PROJECT_ID" `
  -var="redis_password=$redis_password" `
  -var="image_name=$image_name_to_apply" 