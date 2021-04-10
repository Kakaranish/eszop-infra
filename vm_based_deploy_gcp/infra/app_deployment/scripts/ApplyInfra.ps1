param(
  [Parameter(Mandatory = $true)]  
  [string] $ImageName,

  [switch] $Init
)

Import-Module $PSScriptRoot\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if (-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if (-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

Write-Host "[INFO] Running on $env:ASPNETCORE_ENVIRONMENT env" -ForegroundColor Green

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
  -var="environment_prefix=$env_prefix" `
  -var="image_name=$ImageName" 

New-Item -ItemType File -Name ".cache" -Force | Out-Null
Set-Content ".cache" $ImageName