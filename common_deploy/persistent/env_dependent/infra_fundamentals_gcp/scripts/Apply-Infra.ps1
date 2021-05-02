param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [switch] $Init
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_config = Get-InfraConfig -CloudEnv $CloudEnv

if ($Init) {
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
  -var "project_id=$($infra_config.GCP_PROJECT_ID)" `
  -var "env_prefix=$CloudEnv"