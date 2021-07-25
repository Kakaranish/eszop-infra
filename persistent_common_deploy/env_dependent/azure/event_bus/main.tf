locals {
  resource_group  = "eszop-${var.environment}"
}

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