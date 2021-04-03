$subscription_id = ""

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

$config_dir = Resolve-Path -Path "$PSScriptRoot\..\config"

& ".\PrepareSecrets.ps1"

kubectl apply -f "$config_dir\config.yaml"
kubectl apply -f "$config_dir\secrets.yaml"

Start-Sleep -Seconds 20

kubectl apply -f "$config_dir\cert-issuer.yaml"
kubectl apply -f "$config_dir\ingress.yaml"

kubectl apply -f "$config_dir\deployments\api-gateway-deploy.yaml"
kubectl apply -f "$config_dir\deployments\offers-deploy.yaml"
kubectl apply -f "$config_dir\deployments\identity-deploy.yaml"
kubectl apply -f "$config_dir\deployments\carts-deploy.yaml"
kubectl apply -f "$config_dir\deployments\orders-deploy.yaml"
kubectl apply -f "$config_dir\deployments\notification-deploy.yaml"