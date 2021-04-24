resource "azurerm_container_registry" "container_registry" {
  name                = "eszopregistry"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}