resource "azurerm_kubernetes_cluster" "eszop_cluster" {
  name                = "eszop-cluster"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "eszop-cluster"

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