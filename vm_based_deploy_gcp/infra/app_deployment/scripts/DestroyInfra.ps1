Import-Module $PSScriptRoot\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if(-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if(-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

$cache_json = Get-Content -Path ".cache" | ConvertFrom-Json

terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
    -var="environment_prefix=$env_prefix" `
    -var="backend_image_name=${cache_json.backend_image_name}" `
    -var="frontend_image_name=${cache_json.frontend_image_name}"