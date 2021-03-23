# ---  Databases  --------------------------------------------------------------

module "offers_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-offers-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "identity_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-identity-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "carts_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-carts-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "orders_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-orders-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "notification_db" {
  source = "./modules/sql_server"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-notification-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

# ---  SERVICE BUS  ------------------------------------------------------------

resource "azurerm_servicebus_namespace" "service_bus" {
  name                = "eszop-event-bus"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "service_bus_topic" {
  name                = "eszop-event-bus-topic"
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
}

module "identity_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "identity"
}

module "carts_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "carts"
}

module "orders_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "orders"
}

module "notifications_sub" {
  source = "./modules/service_subscription"

  resource_group   = var.resource_group
  topic_name       = azurerm_servicebus_topic.service_bus_topic.name
  service_bus_name = azurerm_servicebus_namespace.service_bus.name
  service_name     = "notifications"
}

output "service_bus_connection_string" {
  value = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
}
