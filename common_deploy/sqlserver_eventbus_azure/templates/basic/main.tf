locals {
  resource_group  = "eszop-${var.environment}"
  sql_server_name = "eszop-${var.environment}-sqlserver"
}

# ---  Databases  --------------------------------------------------------------

module "sql_server" {
  source = "./modules/sql_server"

  resource_group  = local.resource_group
  location        = var.location
  server_name     = local.sql_server_name
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "offers_db" {
  depends_on = [module.sql_server]

  source = "./modules/sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "offers"
}

module "identity_db" {
  depends_on = [module.sql_server]

  source = "./modules/sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "identity"
}

module "carts_db" {
  depends_on = [module.sql_server]

  source = "./modules/sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "carts"
}

module "orders_db" {
  depends_on = [module.sql_server]

  source = "./modules/sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "orders"
}

module "notification_db" {
  depends_on = [module.sql_server]

  source = "./modules/sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "notification"
}

#---  SERVICE BUS  -------------------------------------------------------------

resource "azurerm_servicebus_namespace" "service_bus" {
  name                = "eszop-${var.environment}-event-bus"
  location            = var.location
  resource_group_name = local.resource_group
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "service_bus_topic" {
  name                = "eszop-${var.environment}-event-bus-topic"
  resource_group_name = local.resource_group
  namespace_name      = azurerm_servicebus_namespace.service_bus.name

  enable_partitioning = true
}

# Subscriptions vvv

module "offers_sub" {
  source = "./modules/service_subscription"

  resource_group   = local.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "offers"
  environment      = var.environment
}

module "identity_sub" {
  source = "./modules/service_subscription"

  resource_group   = local.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "identity"
  environment      = var.environment
}

module "carts_sub" {
  source = "./modules/service_subscription"

  resource_group   = local.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "carts"
  environment      = var.environment
}

module "orders_sub" {
  source = "./modules/service_subscription"

  resource_group   = local.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "orders"
  environment      = var.environment
}

module "notification_sub" {
  source = "./modules/service_subscription"

  resource_group   = local.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "notification"
  environment      = var.environment
}

output "service_bus_connection_string" {
  value = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
}
