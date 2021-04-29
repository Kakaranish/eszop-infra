$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"

kubectl delete -f "$config_dir\services\api-gateway-deploy.yaml"
kubectl delete -f "$config_dir\services\offers-deploy.yaml"
kubectl delete -f "$config_dir\services\identity-deploy.yaml"
kubectl delete -f "$config_dir\services\carts-deploy.yaml"
kubectl delete -f "$config_dir\services\orders-deploy.yaml"
kubectl delete -f "$config_dir\services\notification-deploy.yaml"

kubectl delete -f "$config_dir\services\frontend-deploy.yaml"