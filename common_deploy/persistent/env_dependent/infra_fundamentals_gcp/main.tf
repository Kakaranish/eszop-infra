provider "google" {
  project = var.project_id
  region  = "europe-central2-a"
}

data "google_compute_network" "vpc" {
  name = "default"
}

resource "google_compute_address" "redis_address" {
  region       = var.region
  address_type = "EXTERNAL"
  name         = "eszop-${var.env_prefix}-redis-ip"
}

resource "google_compute_global_address" "ingress_address" {
  address_type = "EXTERNAL"
  name         = "eszop-${var.env_prefix}-ingress-ip"
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
