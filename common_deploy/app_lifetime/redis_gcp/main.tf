provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_address" "redis_db_address" {
  project = var.project_id
  region  = var.region
  name    = "eszop-${var.env_prefix}-redis-ip"
}

data "google_compute_network" "vpc" {
  name = "default"
}

resource "google_service_account" "service_account" {
  account_id   = "redis-sa"
  display_name = "redis-sa"
}

resource "google_compute_firewall" "redis_firewall_rule" {
  name    = "redis-access"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "redis_vm" {
  name         = "redis-${var.env_prefix}-db"
  machine_type = "custom-1-1536"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "projects/${var.global_project_id}/global/images/${var.image_name}"
    }
  }

  metadata = {
    startup-script = ". /scripts/boot.sh"
    redis_password = var.redis_password
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = data.google_compute_address.redis_db_address.address
    }
  }

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
}
