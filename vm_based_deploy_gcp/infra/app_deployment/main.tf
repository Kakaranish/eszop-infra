provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  image_name = "eszop-backend-base-1617905865"
}

resource "google_service_account" "service_account" {
  account_id   = "eszop-${var.environment_prefix}-sa"
  display_name = "Service account for ${var.environment_prefix} env"
}

resource "google_compute_instance" "default" {
  name         = "test-vm"
  machine_type = "e2-medium"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "projects/eszop-309916/global/images/${local.image_name}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script                = ". /scripts/boot.sh"
    SERVICE_NAME                  = "offers"
    SERVICE_DLL                   = "Offers.API.dll"
    ASPNETCORE_ENVIRONMENT        = var.environment
    ASPNETCORE_URLS               = "http://+"
    ESZOP_LOGS_DIR                = "/logs"
    ESZOP_AZURE_STORAGE_CONN_STR  = ""
    ESZOP_AZURE_EVENTBUS_CONN_STR = ""
    ESZOP_REDIS_CONN_STR          = ""
    ESZOP_SQLSERVER_CONN_STR      = ""
  }

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
}