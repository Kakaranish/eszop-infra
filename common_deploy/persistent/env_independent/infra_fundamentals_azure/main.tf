resource "azurerm_resource_group" "resource_group" {
  name     = "eszop"
  location = var.location
}

module "container_repo" {
  source = "./modules/container_repo"

  resource_group = azurerm_resource_group.resource_group.name
  location       = var.location
}

module "storage" {
  source = "./modules/storage"

  resource_group = azurerm_resource_group.resource_group.name
  location       = var.location
}
