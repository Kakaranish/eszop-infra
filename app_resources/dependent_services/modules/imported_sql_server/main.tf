locals {
  server_name = "eszop-${var.environment}-${var.service_name}-sqlserver"
}

resource "azurerm_sql_server" "sql_server" {
  name                         = local.server_name
  resource_group_name          = var.resource_group
  location                     = var.location
  administrator_login          = var.sql_sa_login
  administrator_login_password = var.sql_sa_password
  version                      = "12.0"
}

resource "azurerm_sql_firewall_rule" "firewall_rule" {
  depends_on = [azurerm_sql_server.sql_server]

  name                = "InitializerIp"
  resource_group_name = var.resource_group
  server_name         = local.server_name
  start_ip_address    = var.allowed_ip
  end_ip_address      = var.allowed_ip
}

# Allow access to Azure services
resource "azurerm_sql_firewall_rule" "firewall_rule_access_azure_services" {
  depends_on = [azurerm_sql_server.sql_server]

  name                = "InitializerIp"
  resource_group_name = var.resource_group
  server_name         = local.server_name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "sql_db" {
  depends_on = [azurerm_sql_server.sql_server]

  name                = var.db_name
  resource_group_name = var.resource_group
  location            = var.location
  server_name         = local.server_name
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