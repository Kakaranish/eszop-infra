$kubernetes_dir = Resolve-Path -Path "$PSScriptRoot\..\..\kubernetes"

kubectl apply -f "$kubernetes_dir\services\api-gateway-deploy.yaml"
kubectl apply -f "$kubernetes_dir\services\offers-deploy.yaml"
kubectl apply -f "$kubernetes_dir\services\identity-deploy.yaml"
kubectl apply -f "$kubernetes_dir\services\carts-deploy.yaml"
kubectl apply -f "$kubernetes_dir\services\orders-deploy.yaml"
kubectl apply -f "$kubernetes_dir\services\notification-deploy.yaml"

kubectl apply -f "$kubernetes_dir\services\frontend-deploy.yaml"