param(
  [string] $BackupSuffix,
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
    -var="import_suffix=$BackupSuffix" `
    -var-file="$tf_dir\vars\$env:ASPNETCORE_ENVIRONMENT.tfvars"
}