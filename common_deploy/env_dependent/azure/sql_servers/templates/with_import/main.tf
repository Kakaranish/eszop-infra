locals {
  resource_group        = "eszop-${var.environment}"
  sql_server_name       = "eszop-${var.environment}-sqlserver"
  global_resource_group = "eszop"
  backups_container_uri = "https://${var.global_storage_name}.blob.core.windows.net/${var.backups_container_name}"
}

data "azurerm_storage_account" "storage_account" {
  name                = var.global_storage_name
  resource_group_name = local.global_resource_group
}

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

  source = "./modules/imported_sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "offers"

  sql_sa_login          = var.sql_sa_login
  sql_sa_password       = var.sql_sa_password
  backups_container_uri = local.backups_container_uri
  storage_key           = data.azurerm_storage_account.storage_account.primary_access_key
  import_suffix         = var.import_suffix
}

module "identity_db" {
  depends_on = [module.sql_server]

  source = "./modules/imported_sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "identity"

  sql_sa_login          = var.sql_sa_login
  sql_sa_password       = var.sql_sa_password
  backups_container_uri = local.backups_container_uri
  storage_key           = data.azurerm_storage_account.storage_account.primary_access_key
  import_suffix         = var.import_suffix
}

module "carts_db" {
  depends_on = [module.sql_server]

  source = "./modules/imported_sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "carts"

  sql_sa_login          = var.sql_sa_login
  sql_sa_password       = var.sql_sa_password
  backups_container_uri = local.backups_container_uri
  storage_key           = data.azurerm_storage_account.storage_account.primary_access_key
  import_suffix         = var.import_suffix
}

module "orders_db" {
  depends_on = [module.sql_server]

  source = "./modules/imported_sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "orders"

  sql_sa_login          = var.sql_sa_login
  sql_sa_password       = var.sql_sa_password
  backups_container_uri = local.backups_container_uri
  storage_key           = data.azurerm_storage_account.storage_account.primary_access_key
  import_suffix         = var.import_suffix
}

module "notification_db" {
  depends_on = [module.sql_server]

  source = "./modules/imported_sql_db"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  server_name    = local.sql_server_name
  service_name   = "notification"

  sql_sa_login          = var.sql_sa_login
  sql_sa_password       = var.sql_sa_password
  backups_container_uri = local.backups_container_uri
  storage_key           = data.azurerm_storage_account.storage_account.primary_access_key
  import_suffix         = var.import_suffix
}