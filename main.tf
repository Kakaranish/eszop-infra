module "offers_db" {
  source = "./modules/sql-server-db"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-offers-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "identity_db" {
  source = "./modules/sql-server-db"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-identity-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "carts_db" {
  source = "./modules/sql-server-db"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-carts-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "orders_db" {
  source = "./modules/sql-server-db"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-orders-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}

module "notification_db" {
  source = "./modules/sql-server-db"

  resource_group  = var.resource_group
  location        = var.location
  server_name     = "eszop-notification-sqlserver"
  db_name         = "eszop"
  sql_sa_login    = var.sql_sa_login
  sql_sa_password = var.sql_sa_password
  allowed_ip      = var.allowed_ip
}