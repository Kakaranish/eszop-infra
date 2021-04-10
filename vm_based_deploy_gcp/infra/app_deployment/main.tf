provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "service_account" {
  account_id   = "eszop-${var.environment_prefix}-sa"
  display_name = "eszop ${var.environment_prefix} env SA"
}

module "gateway_mig" {
  source = "./modules/mig"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "gateway"
  metadata = {
    startup-script         = ". /scripts/boot.sh"
    SERVICE_NAME           = "gateway"
    SERVICE_DLL            = "API.Gateway.dll"
    ASPNETCORE_ENVIRONMENT = var.environment
    ASPNETCORE_URLS        = "http://+"
    ESZOP_LOGS_DIR         = "/logs"
    ESZOP_CLIENT_URI       = "frontend.eszop"
  }
}

module "offers_mig" {
  source = "./modules/mig"

  project_id            = var.project_id
  region                = var.region
  image_name            = var.image_name
  service_account_email = google_service_account.service_account.email
  service_name          = "offers"
  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "offers"
    SERVICE_DLL                   = "Offers.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = "/logs"
    ESZOP_AZURE_STORAGE_CONN_STR  = ""
    ESZOP_AZURE_EVENTBUS_CONN_STR = ""
    ESZOP_SQLSERVER_CONN_STR      = ""
  }
}