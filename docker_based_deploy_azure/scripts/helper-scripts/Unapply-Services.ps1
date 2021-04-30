$kubernetes_dir = Resolve-Path -Path "$PSScriptRoot\..\..\kubernetes"

kubectl delete -f "$kubernetes_dir\services\api-gateway-deploy.yaml"
kubectl delete -f "$kubernetes_dir\services\offers-deploy.yaml"
kubectl delete -f "$kubernetes_dir\services\identity-deploy.yaml"
kubectl delete -f "$kubernetes_dir\services\carts-deploy.yaml"
kubectl delete -f "$kubernetes_dir\services\orders-deploy.yaml"
kubectl delete -f "$kubernetes_dir\services\notification-deploy.yaml"

kubectl delete -f "$kubernetes_dir\services\frontend-deploy.yaml"