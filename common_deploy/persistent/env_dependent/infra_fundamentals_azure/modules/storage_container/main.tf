data "azurerm_storage_account" "storage_account" {
  resource_group_name = var.global_resource_group
  name                = var.global_storage_name
}

resource "azurerm_storage_container" "storage_account_container" {
  name                  = "eszop-${var.env_prefix}-storage-container"
  storage_account_name  = var.global_storage_name
  container_access_type = "blob"
}
