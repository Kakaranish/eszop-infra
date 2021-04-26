param(
  [switch] $Init,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

$apply_command = @"
terraform ``
  -chdir="$tf_dir" ``
  destroy ``
  -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command