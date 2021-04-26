param(
  [switch] $Init,
  [switch] $AutoApprove
)

$repo_root = "$PSScriptRoot\..\..\..\..\.."
$tf_dir = Resolve-Path "$PSScriptRoot\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -GlobalConfig

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

$apply_command = @"
terraform ``
  -chdir="$tf_dir" ``
  apply ``
  -var="subscription_id=$($infra_global_config.AZ_SUBSCRIPTION_ID)"
"@

if ($AutoApprove.IsPresent) {
  $apply_command = -join ($apply_command, " ```n  -auto-approve")
}

Invoke-Expression $apply_command

if ($LASTEXITCODE -eq 0) {
  $registry_credentials = (az acr credential show --resource-group eszop --name "eszopregistry" | ConvertFrom-Json)
  $docker_image_prefix = (az acr show --resource-group eszop --name eszopregistry --query loginServer -o tsv)

  New-Item -ItemType File -Path "$PSScriptRoot\container_registry_info.yaml" -Force | Out-Null
  $registry_info = @{
    "RegistryLogin"     = $docker_image_prefix;
    "RegistryPassword1" = $registry_credentials.passwords[0].value;
    "RegistryPassword2" = $registry_credentials.passwords[1].value;
    "DockerImagePrefix" = $docker_image_prefix;
  }

  $registry_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\container_registry_info.yaml" -NoNewline

  # ----------------------------------------------------------------------------

  $conn_str = az storage account show-connection-string `
    --resource-group "eszop" `
    --name "eszopstorage" `
    --query "connectionString" `
    -o tsv
  $storage_info = @{ "ConnectionString" = $conn_str; }
  $storage_info | ConvertTo-Yaml | Set-Content "$PSScriptRoot\storage_info.yaml" -NoNewline
}