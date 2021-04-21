param (
    [string] $IngressIpAddress
)
Import-Module $PSScriptRoot\..\Config.psm1 -Force

$sleep_time = 30

if ($IngressIpAddress) {
    Write-Host "[INFO] Using $IngressIpAddress as ingress external IP address" -ForegroundColor Green
    
    Write-Host "[INFO] Installing ingress-nginx" -ForegroundColor Green
    (helm install nginx-ingress ingress-nginx/ingress-nginx `
            --set controller.replicaCount=2 `
            --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
            --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
            --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux `
            --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"="$ip_addr_res_group" `
            --set controller.service.loadBalancerIP="$IngressIpAddress") | Out-Null
  
    Write-Host "[INFO] Waiting for ingress-nginx webhooks | Sleep ${sleep_time}s..." -ForegroundColor Green
    Start-Sleep -Seconds $sleep_time
    kubectl apply -f "$config_dir\ingress.yaml"
}
else {
    Write-Host "[INFO] No static IP address found - ingress IP will be assigned dynamically" -ForegroundColor Green
  
    (helm install nginx-ingress ingress-nginx/ingress-nginx `
            --set controller.replicaCount=2 `
            --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
            --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
            --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux) | Out-Null
  
    $max_retries = 10
    Write-Host "[INFO] Waiting for ingress external IP ." -NoNewline
    Start-Sleep -Seconds 5

    for ($i = 1; $i -le $max_retries; $i++) {
        $services = kubectl get service -o json | ConvertFrom-Json
        $external_ips = @($services.items | `
                Foreach-Object { $_.status.loadBalancer.ingress.ip } | `
                Where-Object { $_ })
        if ($external_ips.Count -eq 1) {
            $IngressIpAddress = $external_ips[0]
            break
        }
  
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 5
    }
    Write-Host ""
  
    if (-not($IngressIpAddress)) {
        Write-Error "Unable to receive ingress external ip" -ErrorAction Stop
    }
    
    Write-Host "[INFO] Waiting for ingress-nginx webhooks | Sleep ${sleep_time}s..." -ForegroundColor Green
    Start-Sleep -Seconds $sleep_time
    kubectl apply -f "$config_dir\ingress-dynamic.yaml"
}