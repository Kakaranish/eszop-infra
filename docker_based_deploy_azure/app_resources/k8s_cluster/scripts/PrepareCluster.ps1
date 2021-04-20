Import-Module $PSScriptRoot\Config.psm1 -Force

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\config"

az account set --subscription $subscription_id
az aks get-credentials `
  --resource-group $cluster_res_group `
  --name $cluster_name `
  --overwrite-existing

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

Write-Host "[INFO] Installing cert-manager" -ForegroundColor Green
(helm install cert-manager jetstack/cert-manager `
    --namespace default `
    --set installCRDs=true `
    --version v0.16.1 `
    --set nodeSelector."kubernetes\.io/os"=linux `
    --set webhook.nodeSelector."kubernetes\.io/os"=linux) | Out-Null

Write-Host "[INFO] Waiting for cert-manager webhooks | Sleep 20s..." -ForegroundColor Green
Start-Sleep -Seconds 20

$ip_addr = az network public-ip show `
  --resource-group $ip_addr_res_group `
  --name $ip_addr_res_name `
  --query ipAddress `
  --output tsv
  
if ($ip_addr) {
  kubectl apply -f "$config_dir\cert-issuer.yaml"
    
  Write-Host "[INFO] Using $ip_addr as ingress external IP address" -ForegroundColor Green
  Write-Host "[INFO] Installing ingress-nginx" -ForegroundColor Green
  (helm install nginx-ingress ingress-nginx/ingress-nginx `
      --set controller.replicaCount=2 `
      --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"="$ip_addr_res_group" `
      --set controller.service.loadBalancerIP="$ip_addr") | Out-Null

  Write-Host "[INFO] Waiting for ingress-nginx webhooks | Sleep 15s..." -ForegroundColor Green
  Start-Sleep -Seconds 15
  kubectl apply -f "$config_dir\ingress.yaml"
}
else {
  kubectl apply -f "$config_dir\cert-issuer-dynamic.yaml"

  Write-Host "[INFO] No static IP address found - ingress IP will be assigned dynamically" -ForegroundColor Green

  (helm install nginx-ingress ingress-nginx/ingress-nginx `
      --set controller.replicaCount=2 `
      --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux) | Out-Null

  $max_retries = 10
  $ip_addr = $null
  Write-Host "[INFO] Waiting for ingress external IP ." -NoNewline
  Start-Sleep -Seconds 5
  for ($i = 1; $i -le $max_retries; $i++) {
    $services = kubectl get service -o json | ConvertFrom-Json
    $external_ips = @($services.items | `
        Foreach-Object { $_.status.loadBalancer.ingress.ip } | `
        Where-Object { $_ })
    if ($external_ips.Count -eq 1) {
      $ip_addr = $external_ips[0]
      break
    }

    Write-Host "." -NoNewline
    Start-Sleep -Seconds 5
  }
  Write-Host ""

  if (-not($ip_addr)) {
    Write-Error "Unable to receive ingress external ip" -ErrorAction Stop
  }
  
  Write-Host "[INFO] Waiting for ingress-nginx webhooks | Sleep 15s..." -ForegroundColor Green
  Start-Sleep -Seconds 15
  kubectl apply -f "$config_dir\ingress-dynamic.yaml"
}

$ingress_extenal_address = if ($domain_name) { $domain_name } else { $ip_addr }
Invoke-Expression "$PSScriptRoot\preparation-scripts\PrepareConfig.ps1 ``
  -IngressExternalAddress $ingress_extenal_address"

& "$PSScriptRoot\preparation-scripts\PrepareSecrets.ps1"
kubectl apply -f "$config_dir\config.yaml"
kubectl apply -f "$config_dir\secrets.yaml"

# ---  Deploy services  --------------------------------------------------------

kubectl apply -f "$config_dir\services\api-gateway-deploy.yaml"
kubectl apply -f "$config_dir\services\offers-deploy.yaml"
kubectl apply -f "$config_dir\services\identity-deploy.yaml"
kubectl apply -f "$config_dir\services\carts-deploy.yaml"
kubectl apply -f "$config_dir\services\orders-deploy.yaml"
kubectl apply -f "$config_dir\services\notification-deploy.yaml"

kubectl apply -f "$config_dir\services\frontend-deploy.yaml"