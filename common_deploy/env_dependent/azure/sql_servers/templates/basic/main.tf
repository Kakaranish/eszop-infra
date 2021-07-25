locals {
  resource_group  = "eszop-${var.environment}"
  sql_server_name = "eszop-${var.environment}-sqlserver"
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