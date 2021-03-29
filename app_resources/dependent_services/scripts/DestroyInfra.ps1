param(
  [string] $BackupSuffix,
  [string] $BackupsContainerUri = "https://eszopstorage.blob.core.windows.net/eszop-db-backups",
  [switch] $Init
)

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if (-not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination "$PSScriptRoot\.."

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="allowed_ip=$my_ip" `
    -var-file="$tf_dir\vars\$env:ASPNETCORE_ENVIRONMENT.tfvars"
}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination "$PSScriptRoot\.."

  terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="allowed_ip=$my_ip" `
    -var="backups_container_uri=$BackupsContainerUri" `
    -var="import_suffix=$BackupSuffix" `
    -var-file="$tf_dir\vars\$env:ASPNETCORE_ENVIRONMENT.tfvars"
}