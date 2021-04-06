resource "azurerm_sql_database" "sql_db" {
  name                = "eszop-${var.environment}-${var.service_name}-db"
  resource_group_name = var.resource_group
  location            = var.location
  server_name         = var.server_name
  edition             = "Basic"
}
