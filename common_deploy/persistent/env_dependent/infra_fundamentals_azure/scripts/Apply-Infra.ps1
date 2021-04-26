param(
  [switch] $Init,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force
Import-Module "${repo_root}\scripts\Get-RequiredEnvPrefix.psm1" -Force -Scope Local

# ------------------------------------------------------------------------------

$env_prefix = Get-RequiredEnvPrefix
$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

(terraform -chdir="$tf_dir" workspace select $env_prefix) | Out-Null
if ($LASTEXITCODE -ne 0) {
  (terraform -chdir="$tf_dir" workspace new $env_prefix) | Out-Null
}
Write-Host "[INFO] Running in '$env_prefix' terraform workspace" -ForegroundColor Green

$apply_command = @"
terraform ``
  -chdir="$tf_dir" ``
  apply ``
  -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)" ``
  -var="env_prefix=${env_prefix}"
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

  New-Item -ItemType File -Path "$PSScriptRoot\output\${env_prefix}_networking.yaml" -Force | Out-Null
  $networking_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\output\${env_prefix}_networking.yaml" -NoNewline
}