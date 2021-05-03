param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv,

  [string] $IngressIpAddress
)

$repo_root = "$PSScriptRoot\..\..\.."
$kubernetes_dir = Resolve-Path -Path "$PSScriptRoot\..\..\kubernetes"

Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

if ($IngressIpAddress) {
  Write-Host "[INFO] Using $IngressIpAddress as ingress external IP address" -ForegroundColor Green
    
  Write-Host "[INFO] Installing ingress-nginx" -ForegroundColor Green

  (helm install nginx-ingress ingress-nginx/ingress-nginx `
      --set controller.replicaCount=2 `
      --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"="eszop-$CloudEnv" `
      --set controller.service.loadBalancerIP="$IngressIpAddress") | Out-Null
  
  kubectl delete -A ValidatingWebhookConfiguration nginx-ingress-ingress-nginx-admission

  kubectl apply -f "$kubernetes_dir\ingress.yaml"
  Write-Host "[INFO] Applied ingress.yaml" -ForegroundColor Green
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
    
  kubectl delete -A ValidatingWebhookConfiguration nginx-ingress-ingress-nginx-admission

  Write-Host "[INFO] Applied ingress.yaml" -ForegroundColor Green
  kubectl apply -f "$kubernetes_dir\ingress-dynamic.yaml"
}