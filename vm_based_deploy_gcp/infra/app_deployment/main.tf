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
    ESZOP_API_URL          = "https://${var.domain_name}/api"
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
    ESZOP_CLIENT_URI       = "https://${var.domain_name}"
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

module "identity_mig" {
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "identity"

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
  source = "./modules/mig_with_region_backend"

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

module "orders_mig" {
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "orders"

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
  source = "./modules/mig_with_region_backend"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.backend_image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "notification-service"

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "notification"
    SERVICE_DLL                   = "NotificationService.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = var.ESZOP_LOGS_DIR
    ESZOP_AZURE_EVENTBUS_CONN_STR = var.ESZOP_AZURE_EVENTBUS_CONN_STR
    ESZOP_SQLSERVER_CONN_STR      = replace(local.ESZOP_SQLSERVER_CONN_STR_TEMPLATE, "{service_name}", "notification")
  }
}

# ------------------------------------------------------------------------------

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name = "external-lb-cert"

  managed {
    domains = [var.domain_name]
  }
}

data "google_compute_global_address" "external_lb_address" {
  name = "external-lb-ip"
}

# --- External https LB --------------------------------------------------------

resource "google_compute_backend_service" "frontend_global_backend" {
  project               = var.project_id
  name                  = "frontend-global-backend-service"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group                 = module.frontend_mig.instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 1000
  }

  health_checks = [module.frontend_mig.healthcheck_id]
}

resource "google_compute_backend_service" "gateway_global_backend" {
  project               = var.project_id
  name                  = "gateway-global-backend-service"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group                 = module.gateway_mig.instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 1000
  }

  health_checks = [module.gateway_mig.healthcheck_id]
}

resource "google_compute_url_map" "external_url_map" {
  name = "external-url-map"

  default_service = google_compute_backend_service.frontend_global_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.frontend_global_backend.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.gateway_global_backend.id
    }
  }
}

resource "google_compute_target_https_proxy" "external_proxy" {
  name             = "external-proxy"
  url_map          = google_compute_url_map.external_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
}

resource "google_compute_global_forwarding_rule" "external_lb_fwd_rule" {
  name       = "external-lb-fwd-rule"
  target     = google_compute_target_https_proxy.external_proxy.id
  port_range = "443"
  ip_address = data.google_compute_global_address.external_lb_address.address
}
