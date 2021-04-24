locals {
  global_storage_account_name = "eszopstorage"
  global_resource_group       = "eszop"
  env_resource_group          = "eszop-${var.environment}"
}

data "azurerm_storage_account" "storage_account" {
  name                = local.global_storage_account_name
  resource_group_name = local.global_resource_group
}

resource "azurerm_storage_container" "storage_account_container" {
  name                  = "eszop-${var.environment}-storage-container"
  storage_account_name  = local.global_storage_account_name
  container_access_type = "blob"
}
