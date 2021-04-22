param (
    [string] $IngressIpAddress,
    [switch] $UseSelfSigned
)
Import-Module $PSScriptRoot\..\Config.psm1 -Force

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"
$sleep_time = 30

Write-Host "[INFO] Installing cert-manager" -ForegroundColor Green
(helm install cert-manager jetstack/cert-manager `
        --namespace default `
        --set installCRDs=true `
        --set nodeSelector."kubernetes\.io/os"=linux `
        --set webhook.nodeSelector."kubernetes\.io/os"=linux) | Out-Null

Write-Host "[INFO] Waiting for cert-manager webhooks | Sleep ${sleep_time}s..." -ForegroundColor Green
Start-Sleep -Seconds $sleep_time

if ($UseSelfSigned.IsPresent -or $ip_addr) {
    Write-Host "[INFO] Applying self-signed cert issuer"
    kubectl apply -f "$config_dir\selfsigned-cert-issuer.yaml"
}
else {
    Write-Host "[INFO] Applying cert issuer"
    kubectl apply -f "$config_dir\cert-issuer.yaml"
}