provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  ESZOP_SQLSERVER_CONN_STR_TEMPLATE = "Server=tcp:eszop-${var.environment_prefix}-sqlserver.database.windows.net,1433;Initial Catalog=eszop-${var.environment_prefix}-{service_name}-db;Persist Security Info=False;User ID=${var.sql_server_db_username};Password=${var.sql_server_db_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

resource "google_service_account" "service_account" {
  account_id   = "eszop-${var.environment_prefix}-sa"
  display_name = "eszop ${var.environment_prefix} env SA"
}

module "frontend_mig" {
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.frontend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "frontend"

  metadata = {
    startup-script         = ". /scripts/boot.sh"
    ASPNETCORE_ENVIRONMENT = var.environment
    ESZOP_API_URL          = "gateway.eszop"
  }
}

module "gateway_mig" {
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "gateway"

  metadata = {
    startup-script         = ". /scripts/boot.sh"
    SERVICE_NAME           = "gateway"
    SERVICE_DLL            = "API.Gateway.dll"
    ASPNETCORE_ENVIRONMENT = var.environment
    ASPNETCORE_URLS        = "http://+"
    ESZOP_LOGS_DIR         = var.ESZOP_LOGS_DIR
    ESZOP_CLIENT_URI       = var.ESZOP_CLIENT_URI
  }
}

module "offers_mig" {
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "offers"

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "offers"
    SERVICE_DLL                   = "Offers.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_STORAGE_CONN_STR  = var.ESZOP_AZURE_STORAGE_CONN_STR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "offers")
  }
}

module "carts_mig" {
  source = "./modules/backend-mig"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "carts"

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "carts"
    SERVICE_DLL                   = "Carts.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "carts")
  }
}
