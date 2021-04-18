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
  source = "./modules/mig"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.frontend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "frontend"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

  metadata = {
    startup-script         = ". /scripts/boot.sh"
    ASPNETCORE_ENVIRONMENT = var.environment
    ESZOP_API_URL          = "https://${var.domain_name}/api"
  }
}

module "gateway_mig" {
  source = "./modules/mig"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "gateway"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

  metadata = {
    startup-script         = ". /scripts/boot.sh"
    SERVICE_NAME           = "gateway"
    SERVICE_DLL            = "API.Gateway.dll"
    ASPNETCORE_ENVIRONMENT = var.environment
    ASPNETCORE_URLS        = "http://+"
    ESZOP_LOGS_DIR         = var.ESZOP_LOGS_DIR
    ESZOP_CLIENT_URI       = "https://${var.domain_name}"
  }
}

module "external_https_lb" {
  source = "./modules/external_https_lb"

  project_id                      = var.project_id
  region                          = var.region
  domain_name                     = var.domain_name
  frontend_service_mig            = module.frontend_mig.instance_group
  frontend_service_healthcheck_id = module.frontend_mig.healthcheck_id
  gateway_service_mig             = module.gateway_mig.instance_group
  gateway_service_healthcheck_id  = module.gateway_mig.healthcheck_id
}

module "external_http_to_https_lb" {
  source = "./modules/external_http_to_https_lb"
}

module "offers_mig" {
  source = "./modules/mig_with_internal_lb"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "offers"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

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

module "identity_mig" {
  source = "./modules/mig_with_internal_lb"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "identity"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "identity"
    SERVICE_DLL                   = "Identity.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_REDIS_CONN_STR          = var.ESZOP_REDIS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "identity")
  }
}

module "carts_mig" {
  source = "./modules/mig_with_internal_lb"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "carts"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

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

module "orders_mig" {
  source = "./modules/mig_with_internal_lb"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "orders"
  min_replicas          = var.min_replicas
  max_replicas          = var.max_replicas
  machine_type          = var.machine_type

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "orders"
    SERVICE_DLL                   = "Orders.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "orders")
  }
}

module "notification_service_mig" {
  source = "./modules/mig_with_internal_lb"

  project_id              = var.project_id
  region                  = var.region
  image_name              = var.backend_image_name
  service_account_email   = google_service_account.service_account.email
  service_name            = "notification-service"
  min_replicas            = var.min_replicas
  max_replicas            = var.max_replicas
  machine_type            = var.machine_type
  backend_svc_timeout_sec = 86400

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "notification"
    SERVICE_DLL                   = "NotificationService.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_REDIS_CONN_STR          = var.ESZOP_REDIS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "notification")
  }
}
