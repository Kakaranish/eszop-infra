locals {
  resource_group = "eszop-${var.env_prefix}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group
  location = var.location
}

module "networking" {
  source     = "./modules/networking"
  depends_on = [azurerm_resource_group.resource_group]

  resource_group = local.resource_group
  location       = var.location
}

module "storage_container" {
  source     = "./modules/storage_container"
  depends_on = [azurerm_resource_group.resource_group]

  global_resource_group = var.global_resource_group
  global_storage_name   = var.global_storage_name
  location              = var.location
  env_prefix            = var.env_prefix
}

module "identity" {
  source     = "./modules/identity"
  depends_on = [azurerm_resource_group.resource_group]

  location   = var.location
  env_prefix = var.env_prefix
}
