resource "azurerm_sql_server" "sql_server" {
  name                         = var.server_name
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
  server_name         = var.server_name
  start_ip_address    = var.allowed_ip
  end_ip_address      = var.allowed_ip
}

resource "azurerm_sql_database" "sql_db" {
  depends_on = [azurerm_sql_server.sql_server]

  name                = var.db_name
  resource_group_name = var.resource_group
  location            = var.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = "Basic"
}