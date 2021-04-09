Import-Module $PSScriptRoot\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if(-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if(-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

$image_name = Get-Content ".cache"

terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="environment=$env:ASPNETCORE_ENVIRONMENT" `
    -var="environment_prefix=$env_prefix" `
    -var="image_name=$image_name"