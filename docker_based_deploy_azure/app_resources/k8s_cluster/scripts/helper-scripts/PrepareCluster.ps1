param (
  [switch] $UseSelfSignedCertificates
)

Import-Module $PSScriptRoot\..\Config.psm1 -Force

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"

az account set --subscription $subscription_id
az aks get-credentials `
  --resource-group $cluster_res_group `
  --name $cluster_name `
  --overwrite-existing

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

$ip_addr = az network public-ip show `
  --resource-group $ip_addr_res_group `
  --name $ip_addr_res_name `
  --query ipAddress `
  --output tsv

if (-not($ip_addr)) {
  Write-Host "[INFO] No static IP address found - ingress IP will be assigned dynamically" -ForegroundColor Green
}

$additionalCertIssuerParams = @{}
if ($UseSelfSignedCertificates.IsPresent) {
  $additionalCertIssuerParams.Add("UseSelfSigned", $True)
}

& "$PSScriptRoot\ApplyCertIssuer.ps1" -IngressIpAddress $ip_addr @additionalCertIssuerParams
& "$PSScriptRoot\ApplyIngress.ps1" -IngressIpAddress $ip_addr

$ingress_extenal_address = if ($domain_name) { $domain_name } else { $ip_addr }
Invoke-Expression "$PSScriptRoot\PrepareConfig.ps1 ``
  -IngressExternalAddress $ingress_extenal_address"

& "$PSScriptRoot\PrepareSecrets.ps1"
kubectl apply -f "$config_dir\config.yaml"
kubectl apply -f "$config_dir\secrets.yaml"

& "$PSScriptRoot\ApplyServices.ps1"