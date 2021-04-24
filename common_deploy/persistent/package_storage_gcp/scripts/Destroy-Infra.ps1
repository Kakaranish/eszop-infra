param (
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var "project_id=$($infra_global_config.GCP_PROJECT_ID)"