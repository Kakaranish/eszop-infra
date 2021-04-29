param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

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

(terraform -chdir="$tf_dir" workspace select $CloudEnv) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $CloudEnv) | Out-Null
}
Write-Host "[INFO] Running in '$CloudEnv' terraform workspace" -ForegroundColor Green

$apply_command = @"
terraform ``
  -chdir="$tf_dir" ``
  apply ``
  -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
  -var="env_prefix=$CloudEnv"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command

if ($LASTEXITCODE -eq 0) {
  if (-not(Test-Path "$PSScriptRoot\output")) {
    New-Item -ItemType Directory -Name "output" | Out-Null
  }

  $ip_addr = az network public-ip show `
    --resource-group eszop-staging `
    --name eszop-public `
    --query ipAddress `
    -o tsv
  $networking_info = @{ "ReservedIpAddress" = $ip_addr }

  $networking_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\output\${CloudEnv}_networking.yaml" -NoNewline
}