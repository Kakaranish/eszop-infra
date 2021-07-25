param(
  [switch] $Init,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -CloudEnv "global"

if ($Init) {
  terraform -chdir="$tf_dir" init
}

$apply_command = @"
terraform ``
  -chdir="$tf_dir" ``
  destroy ``
  -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
  -var="storage_name=$($infra_global_config.AZ_STORAGE_NAME)"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command

if ($LASTEXITCODE -eq 0) {
  $envs_to_update = @("dev", "staging", "prod")
  $infra_output = @{"AZURE_STORAGE_CONN_STR" = "NEEDS_TO_BE_GENERATED"; }
  foreach ($env in $envs_to_update) {
    Update-InfraConfigOutput `
      -CloudEnv $env `
      -Entries $infra_output 
  }
}