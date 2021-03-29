param(
  [string] $BackupSuffix,
  [string] $BackupsContainerUri = "https://eszopstorage.blob.core.windows.net/eszop-db-backups",
  [switch] $Init
)

$default_environment = "Staging"
$environment = $env:ASPNETCORE_ENVIRONMENT
if (-not($environment)) {
  $environment = $default_environment
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."
$my_ip = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

if (-not($BackupSuffix)) {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\basic" | Copy-Item -Destination $tf_dir

  if ($Init) {
    terraform.exe -chdir="$tf_dir" init
  }

  terraform.exe `
    -chdir="$tf_dir" `
    apply `
    -var="allowed_ip=$my_ip" `
    -var-file="$tf_dir\vars\$environment.tfvars"
}
else {
  Get-ChildItem -Path "$PSScriptRoot\..\templates\with_import" | Copy-Item -Destination $tf_dir

  if ($Init) {
    terraform.exe -chdir="$tf_dir" init
  }

  terraform.exe `
    -chdir="$tf_dir" `
    apply `
    -var="allowed_ip=$my_ip" `
    -var="backups_container_uri=$BackupsContainerUri" `
    -var="import_suffix=$BackupSuffix" `
    -var-file="$tf_dir\vars\$environment.tfvars"
}