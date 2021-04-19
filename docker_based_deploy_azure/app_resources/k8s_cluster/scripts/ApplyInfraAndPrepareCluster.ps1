Import-Module .\Config.psm1 -Force

$resource_group = "eszop-staging"
$cluster_name = "eszop-staging-cluster"

& .\ApplyInfra.ps1 -Init -AutoApprove

az account set --subscription $subscription_id
az aks get-credentials `
    --resource-group $resource_group `
    --name $cluster_name `
    --overwrite-existing

& .\PrepareCluster.ps1