param (
  [string] $IngressIpAddress,
  [switch] $UseSelfSigned
)

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"

# ------------------------------------------------------------------------------

kubectl create namespace cert-manager

Write-Host "[INFO] Installing cert-manager" -ForegroundColor Green
(helm install cert-manager jetstack/cert-manager `
    --namespace cert-manager `
    --set installCRDs=true `
    --set nodeSelector."kubernetes\.io/os"=linux) | Out-Null

kubectl delete mutatingwebhookconfiguration.admissionregistration.k8s.io cert-manager-webhook | Out-Null
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io cert-manager-webhook | Out-Null

if ($UseSelfSigned.IsPresent) {
  Write-Host "[INFO] Applying self-signed cert issuer"
  kubectl apply -f "$config_dir\selfsigned-cert-issuer.yaml"
}
else {
  Write-Host "[INFO] Applying cert issuer"
  kubectl apply -f "$config_dir\cert-issuer.yaml"
}