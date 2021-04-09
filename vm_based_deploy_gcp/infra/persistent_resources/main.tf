provider "google" {
  project = var.project_id
  region  = "europe-central2-a"
}

resource "google_storage_bucket" "eszop_app_storage" {
  name          = "eszop-app-storage"
  location      = "EU"
  force_destroy = true
  storage_class = "NEARLINE"
}

data "google_compute_network" "vpc" {
  name = "default"
}

resource "google_compute_firewall" "firewall" {
  name    = "healthcheck-probe"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

resource "google_dns_managed_zone" "dns_zone" {
  name        = "eszop-dns-zone"
  dns_name    = "eszop."
  description = "eszop dns name"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.vpc.id
    }
  }
}
