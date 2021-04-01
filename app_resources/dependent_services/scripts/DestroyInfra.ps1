param(
  [string] $BackupSuffix,
  [string] $BackupsContainerUri = "https://eszopstorage.blob.core.windows.net/eszop-db-backups",
  [switch] $Init
)

Import-Module $PSScriptRoot\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

if(-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if(-not($env_prefix)) {
  Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if (-not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination "$PSScriptRoot\.."

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="allowed_ip=$my_ip" `
    -var-file="$tf_dir\vars\$env_prefix.tfvars"
}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination "$PSScriptRoot\.."

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="allowed_ip=$my_ip" `
    -var="backups_container_uri=$BackupsContainerUri" `
    -var="import_suffix=$BackupSuffix" `
    -var-file="$tf_dir\vars\$env_prefix.tfvars"
}