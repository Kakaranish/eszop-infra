resource "azurerm_public_ip" "public_address" {
  name                = "eszop-${var.env_prefix}-ingress-ip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
