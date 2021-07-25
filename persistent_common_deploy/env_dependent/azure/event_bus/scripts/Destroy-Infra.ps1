param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-AppsConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Update-InfraConfigOutput.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -CloudEnv "global"

terraform -chdir="$tf_dir" init

(terraform -chdir="$tf_dir" workspace select $CloudEnv) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $CloudEnv) | Out-Null
}
Write-Host "[INFO] Running in '$CloudEnv' terraform workspace" -ForegroundColor Green

$apply_command = @"
  terraform ``
    -chdir="$tf_dir" ``
    destroy ``
    -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
    -var="environment=$CloudEnv"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command
if ($LASTEXITCODE -ne 0) {
  Exit
}

# ---  Update AppsConfig  ------------------------------------------------------

$infra_output = @{"AZURE_EVENTBUS_CONN_STR" = "NEEDS_TO_BE_GENERATED" }
Update-InfraConfigOutput `
  -CloudEnv $CloudEnv `
  -Entries $infra_output