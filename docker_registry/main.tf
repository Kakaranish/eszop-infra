resource "azurerm_container_registry" "container_registry" {
  name                = "eszopregistry"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "registry_admin_username" {
  value = azurerm_container_registry.container_registry.admin_username
}
output "registry_admin_password" {
  value = azurerm_container_registry.container_registry.admin_password
}
