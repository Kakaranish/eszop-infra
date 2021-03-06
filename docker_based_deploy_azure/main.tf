locals {
  global_resource_group    = "eszop"
  resource_group           = "eszop-${var.env_prefix}"
  cluster_name             = "eszop-${var.env_prefix}-cluster"
  ingress_address_res_name = "eszop-${var.env_prefix}-ingress-ip"
}

# ---  Existing resources  -----------------------------------------------------

data "azurerm_container_registry" "container_registry" {
  resource_group_name = local.global_resource_group
  name                = "eszopregistry"
}

data "azurerm_public_ip" "cluster_ip" {
  resource_group_name = local.resource_group
  name                = local.ingress_address_res_name
}

data "azurerm_user_assigned_identity" "managed_identity" {
  resource_group_name = local.resource_group
  name                = "eszop-${var.env_prefix}-managed-identity"
}

# ------------------------------------------------------------------------------

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
    type                      = "UserAssigned"
    user_assigned_identity_id = data.azurerm_user_assigned_identity.managed_identity.id
  }
}

resource "azurerm_role_assignment" "acr_role_assignment" {
  principal_id         = azurerm_kubernetes_cluster.kube_cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
}
