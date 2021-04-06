locals {
  global_resource_group = "eszop"
  resource_group        = "eszop-${var.environment}"
  cluster_name          = "eszop-${var.environment}-cluster"
}

resource "azurerm_kubernetes_cluster" "kube_cluster" {
  name                = local.cluster_name
  dns_prefix          = local.cluster_name
  location            = var.location
  resource_group_name = local.resource_group

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }
}

data "azurerm_container_registry" "container_registry" {
  resource_group_name = local.global_resource_group
  name                = "eszopregistry"
}

resource "azurerm_role_assignment" "cluster_to_acr" {
  scope                = data.azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.kube_cluster.kubelet_identity[0].object_id
}
