$config_dir = Resolve-Path -Path "$PSScriptRoot\..\..\config"

kubectl apply -f "$config_dir\services\api-gateway-deploy.yaml"
kubectl apply -f "$config_dir\services\offers-deploy.yaml"
kubectl apply -f "$config_dir\services\identity-deploy.yaml"
kubectl apply -f "$config_dir\services\carts-deploy.yaml"
kubectl apply -f "$config_dir\services\orders-deploy.yaml"
kubectl apply -f "$config_dir\services\notification-deploy.yaml"

kubectl apply -f "$config_dir\services\frontend-deploy.yaml"