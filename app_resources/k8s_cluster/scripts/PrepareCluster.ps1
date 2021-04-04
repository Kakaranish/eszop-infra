Import-Module $PSScriptRoot\Config.psm1 -Force

az account set --subscription $subscription_id
az aks get-credentials --resource-group eszop-staging --name eszop-staging-cluster --overwrite-existing

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx `
  --set controller.replicaCount=2 `
  --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
  --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
  --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

helm install cert-manager jetstack/cert-manager `
  --namespace default `
  --set installCRDs=true `
  --set nodeSelector."kubernetes\.io/os"=linux `
  --set webhook.nodeSelector."kubernetes\.io/os"=linux `
  --set cainjector.nodeSelector."kubernetes\.io/os"=linux

$max_retries = 10
$ingress_external_ip = $null
Write-Host "[INFO] Waiting for ingress external IP ." -NoNewline
Start-Sleep -Seconds 5
for ($i = 1; $i -le $max_retries; $i++) {
  $services = kubectl get service -o json | ConvertFrom-Json
  $external_ips = @($services.items | `
      Foreach-Object { $_.status.loadBalancer.ingress.ip } | `
      Where-Object { $_ })
  if ($external_ips.Count -eq 1) {
    $ingress_external_ip = $external_ips[0]
    break
  }

  Write-Host "." -NoNewline
  Start-Sleep -Seconds 5
}
Write-Host ""

if(-not($ingress_external_ip)) {
  Write-Error "Unable to receive ingress external ip" -ErrorAction Stop
}

Invoke-Expression "$PSScriptRoot\preparation-scripts\PrepareConfig.ps1 -IngressExternalIP $ingress_external_ip"
& "$PSScriptRoot\preparation-scripts\PrepareSecrets.ps1"

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\config"

kubectl apply -f "$config_dir\config.yaml"
kubectl apply -f "$config_dir\secrets.yaml"

kubectl apply -f "$config_dir\cert-issuer.yaml"
kubectl apply -f "$config_dir\ingress.yaml"

kubectl apply -f "$config_dir\deployments\api-gateway-deploy.yaml"
kubectl apply -f "$config_dir\deployments\offers-deploy.yaml"
kubectl apply -f "$config_dir\deployments\identity-deploy.yaml"
kubectl apply -f "$config_dir\deployments\carts-deploy.yaml"
kubectl apply -f "$config_dir\deployments\orders-deploy.yaml"
kubectl apply -f "$config_dir\deployments\notification-deploy.yaml"