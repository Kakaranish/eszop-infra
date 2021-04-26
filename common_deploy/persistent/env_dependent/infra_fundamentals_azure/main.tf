locals {
  resource_group = "eszop-${var.env_prefix}"
}

module "networking" {
  source = "./modules/networking"

  resource_group = local.resource_group
  location       = var.location
}

module "storage_container" {
  source = "./modules/storage_container"

  global_resource_group = var.global_resource_group
  global_storage_name   = var.global_storage_name
  location              = var.location
  env_prefix            = var.env_prefix
}

module "identity" {
  source = "./modules/identity"

  location   = var.location
  env_prefix = var.env_prefix
}
