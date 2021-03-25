locals {
  storage_account_name = "eszopstorage"
}

# ---  Storage account  --------------------------------------------------------

data "azurerm_storage_account" "storage_account" {
  name                = local.storage_account_name
  resource_group_name = var.resource_group
}

resource "azurerm_storage_container" "storage_account_container" {
  name                  = "eszop-${var.environment}-storage-container"
  storage_account_name  = local.storage_account_name
  container_access_type = "blob"
}

# ---  Databases  --------------------------------------------------------------

module "offers_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-${var.environment}-offers-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "identity_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-${var.environment}-identity-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "carts_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-${var.environment}-carts-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "orders_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-${var.environment}-orders-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "notification_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-${var.environment}-notification-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

# ---  SERVICE BUS  ------------------------------------------------------------

resource "azurerm_servicebus_namespace" "service_bus" {
  name                = "eszop-${var.environment}-event-bus"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "service_bus_topic" {
  name                = "eszop-${var.environment}-event-bus-topic"
  resource_group_name = var.resource_group
  namespace_name      = azurerm_servicebus_namespace.service_bus.name

  enable_partitioning = true
}

# Subscriptions vvv

module "offers_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "offers"
  environment      = var.environment
}

module "identity_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "identity"
  environment      = var.environment
}

module "carts_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "carts"
  environment      = var.environment
}

module "orders_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "orders"
  environment      = var.environment
}

module "notifications_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "notifications"
  environment      = var.environment
}

output "service_bus_connection_string" {
  value = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
}
