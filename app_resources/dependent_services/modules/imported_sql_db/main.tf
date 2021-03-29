resource "azurerm_sql_database" "sql_db" {
  name                = "eszop-${var.environment}-${var.service_name}-db"
  resource_group_name = var.resource_group
  location            = var.location
  server_name         = var.server_name
  edition             = "Basic"

  import {
    authentication_type          = "SQL"
    administrator_login          = var.sql_sa_login
    administrator_login_password = var.sql_sa_password
    storage_key_type             = "StorageAccessKey"
    storage_key                  = var.storage_key
    storage_uri                  = "${var.backups_container_uri}/eszop-${var.environment}-${var.service_name}-sqlserver-backup-${var.import_suffix}.bacpac"
  }
}
