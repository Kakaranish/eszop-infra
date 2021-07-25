locals {
  resource_group = "eszop-${var.env_prefix}"
}

data "azurerm_resource_group" "env_resource_group" {
  name = local.resource_group
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "eszop-${var.env_prefix}-managed-identity"
  resource_group_name = local.resource_group
  location            = var.location
}

resource "azurerm_role_assignment" "rg_role_assignment" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_resource_group.env_resource_group.id
}
