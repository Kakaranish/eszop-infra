locals {
  subscription_name = "eszop-event-bus-${var.service_name}-sub"
}

resource "azurerm_servicebus_subscription" "service_bus_sub" {
  name                = local.subscription_name
  resource_group_name = var.resource_group
  namespace_name      = var.service_bus_name
  topic_name          = var.topic_name
  max_delivery_count  = 1
}

# This rule is created to get rid of $DEFAULT filter
resource "azurerm_servicebus_subscription_rule" "service_bus_sub_rule" {
  depends_on = [azurerm_servicebus_subscription.service_bus_sub]
  
  name                = "dummy_rule"
  resource_group_name = var.resource_group
  namespace_name      = var.service_bus_name
  topic_name          = var.topic_name
  subscription_name   = local.subscription_name
  filter_type         = "CorrelationFilter"

  correlation_filter {
    properties = {
      dummy = "true"
    }
  }
}