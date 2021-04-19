param(
  [switch] $Init,
  [switch] $AutoApprove
)

Import-Module $PSScriptRoot\..\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if (-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if (-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

$apply_command = @"
terraform.exe ``
  -chdir="$tf_dir" ``
  apply ``
  -var="environment=$env_prefix"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = @"
$apply_command ``
  -auto-approve 
"@
}

Invoke-Expression $apply_command