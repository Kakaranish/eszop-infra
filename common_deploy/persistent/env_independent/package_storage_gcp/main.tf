provider "google" {
  project = var.project_id
  region  = "europe-central2-a"
}

resource "google_storage_bucket" "package_storage" {
  name          = "eszop-package-storage"
  location      = "EU"
  force_destroy = true
  storage_class = "NEARLINE"
}
