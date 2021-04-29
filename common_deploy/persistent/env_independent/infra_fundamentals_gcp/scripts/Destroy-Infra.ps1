param (
  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -CloudEnv "global"

if ($Init) {
  terraform -chdir="$tf_dir" init
}

terraform `
  -chdir="$tf_dir" `
  destroy `
  -var "project_id=$($infra_global_config.GCP_PROJECT_ID)"