param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [switch] $UseSelfSignedCertificates
)

$repo_root = "$PSScriptRoot\..\..\.."
$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$infra_global_config = Get-InfraConfig -CloudEnv "global"
$infra_config = Get-InfraConfig -CloudEnv $CloudEnv

az account set --subscription $infra_global_config.AZ_SUBSCRIPTION_ID
az aks get-credentials `
  --resource-group $infra_config.AZ_RESOURCE_GROUP `
  --name "$($infra_config.AZ_RESOURCE_GROUP)-cluster" `
  --overwrite-existing

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

$ip_addr = az network public-ip show `
  --resource-group $infra_config.AZ_RESOURCE_GROUP `
  --name $infra_config.AZ_CLUSTER_INGRESS_ADDRESS_RES_NAME `
  --query ipAddress `
  --output tsv

if (-not($ip_addr)) {
  Write-Host "[INFO] No static IP address found - ingress IP will be assigned dynamically" -ForegroundColor Green
}

$additionalCertIssuerParams = @{}
if ($UseSelfSignedCertificates.IsPresent) {
  $additionalCertIssuerParams.Add("UseSelfSigned", $True)
}

. "$PSScriptRoot\Apply-CertIssuer.ps1" -IngressIpAddress $ip_addr @additionalCertIssuerParams
. "$PSScriptRoot\Apply-Ingress.ps1" `
  -CloudEnv $CloudEnv `
  -IngressIpAddress $ip_addr

$ingress_extenal_address = if ($domain_name) { $domain_name } else { $ip_addr }
Invoke-Expression "$PSScriptRoot\Prepare-Config.ps1 ``
  -IngressExternalAddress $ingress_extenal_address"

. "$PSScriptRoot\Prepare-Secrets.ps1" -CloudEnv $CloudEnv

kubectl apply -f "$config_dir\config.yaml"
kubectl apply -f "$config_dir\secrets.yaml"

. "$PSScriptRoot\Apply-Services.ps1"