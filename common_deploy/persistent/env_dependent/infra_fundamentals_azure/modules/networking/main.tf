resource "azurerm_public_ip" "public_address" {
  name                = "eszop-public"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
