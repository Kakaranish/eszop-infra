param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [switch] $UseSelfSignedCertificates
)

$repo_root = "$PSScriptRoot\..\.."

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_config = Get-InfraConfig -CloudEnv $CloudEnv
$infra_global_config = Get-InfraConfig -CloudEnv "global"

& "$PSScriptRoot\Apply-Infra.ps1" `
  -CloudEnv $CloudEnv `
  -Init `
  -AutoApprove

az account set --subscription $infra_global_config.AZ_SUBSCRIPTION_ID
az aks get-credentials `
  --resource-group $infra_config.AZ_RESOURCE_GROUP `
  --name "$($infra_config.AZ_RESOURCE_GROUP)-cluster" `
  --overwrite-existing

$params = @{}
if ($UseSelfSignedCertificates.IsPresent) {
  $params.Add("UseSelfSignedCertificates", $True)
}

. "$PSScriptRoot\helper-scripts\Prepare-Cluster.ps1" -CloudEnv $CloudEnv @params