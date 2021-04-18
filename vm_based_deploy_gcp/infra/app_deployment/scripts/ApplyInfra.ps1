param(
  [string] $BackendImageName,
  [string] $FrontendImageName,
  [switch] $Init,
  [switch] $UsePreviousParams
)

Import-Module $PSScriptRoot\..\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if (-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}
$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if (-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

if ($UsePreviousParams.IsPresent) {
  $cache_json = Get-Content -Path ".cache" | ConvertFrom-Json
  $BackendImageName = $cache_json.backend_image_name
  $FrontendImageName = $cache_json.frontend_image_name
}

if (-not($BackendImageName)) {
  Write-Error "BackendImageName cannot be empty" -ErrorAction Stop
}
if (-not($FrontendImageName)) {
  Write-Error "FrontendImageName cannot be empty" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

Write-Host "[INFO] Running with params:" -ForegroundColor Green
Write-Host "[INFO] Environment: $env:ASPNETCORE_ENVIRONMENT" -ForegroundColor Green
Write-Host "[INFO] BackendImageName: $BackendImageName" -ForegroundColor Green
Write-Host "[INFO] FrontendImageName: $FrontendImageName" -ForegroundColor Green

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
  -var="environment_prefix=$env_prefix" `
  -var="backend_image_name=$BackendImageName" `
  -var="frontend_image_name=$FrontendImageName"


$cache_content = @{
  backend_image_name  = $BackendImageName;
  frontend_image_name = $FrontendImageName
}
New-Item -ItemType File -Name ".cache" -Force | Out-Null
$cache_content | ConvertTo-Json | Set-Content ".cache"