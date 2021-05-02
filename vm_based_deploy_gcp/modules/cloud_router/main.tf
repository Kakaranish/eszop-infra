data "google_compute_network" "vpc" {
  name = "default"
}
resource "google_compute_router" "cloud_router" {
  name    = "cloud-router"
  region  = var.region
  network = data.google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.cloud_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
