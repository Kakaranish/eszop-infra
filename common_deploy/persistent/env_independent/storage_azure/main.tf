resource "azurerm_storage_account" "storage_account" {
  name                     = "eszopstorage"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "db_backups_storage_account_container" {
  name                  = "eszop-db-backups"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}
