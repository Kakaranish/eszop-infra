locals {
  resource_group = "eszop-${var.environment}-rg"
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  depends_on = [azurerm_resource_group.resource_group]

  name                     = "eszop${replace(var.environment, "-", "")}storage"
  resource_group_name      = local.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "storage_account_container" {
  depends_on = [azurerm_storage_account.storage_account]

  name                  = "eszop-${var.environment}-storage-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

resource "azurerm_container_registry" "container_registry" {
  depends_on = [azurerm_resource_group.resource_group]

  name                = "eszop${replace(var.environment, "-", "")}registry"
  resource_group_name = local.resource_group
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
output "storage_connection_string" {
  value = azurerm_storage_account.storage_account.primary_connection_string
}
