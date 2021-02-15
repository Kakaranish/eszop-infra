locals {
  resource_group = "eSzop"
  location = "West Europe"
}

resource "azurerm_sql_server" "sql_server" {
  name                         = "eszop-sqlserver"
  resource_group_name          = local.resource_group
  location                     = local.location
  administrator_login          = var.sql_sa_login
  administrator_login_password = var.sql_sa_password
  version = "12.0"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_database" "sql_carts_db" {
  name                = "eszopcartsdb"
  resource_group_name = local.resource_group
  location            = local.location
  server_name         = azurerm_sql_server.sql_server.name
  edition = "Basic"
  
  tags = {
    environment = "dev"
  }
}