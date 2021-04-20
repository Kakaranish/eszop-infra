Import-Module .\Config.psm1 -Force

& .\ApplyInfra.ps1 -Init -AutoApprove

az account set --subscription $subscription_id
az aks get-credentials `
    --resource-group $cluster_res_group `
    --name $cluster_name `
    --overwrite-existing

& .\PrepareCluster.ps1