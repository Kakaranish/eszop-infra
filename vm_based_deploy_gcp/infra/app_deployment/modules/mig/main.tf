resource "google_compute_instance_template" "compute_engine_template" {
  project      = var.project_id
  region       = var.region
  name         = "${var.service_name}-cit"
  machine_type = "e2-medium"

  metadata = var.metadata

  network_interface {
    network = "default"
    access_config {}
  }

  disk {
    source_image = "projects/${var.project_id}/global/images/${var.image_name}"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_health_check" "healtcheck" {
  name = "${var.service_name}-healthcheck"

  http_health_check {
    port         = 80
    request_path = var.healthcheck_path
  }
}

resource "google_compute_region_instance_group_manager" "instance_group" {
  project            = var.project_id
  region             = var.region
  name               = "${var.service_name}-mig"
  base_instance_name = var.service_name

  auto_healing_policies {
    health_check      = google_compute_health_check.healtcheck.id
    initial_delay_sec = 60
  }

  version {
    instance_template = google_compute_instance_template.compute_engine_template.self_link
  }
}

resource "google_compute_region_autoscaler" "compute_engine_autoscaler" {
  project = var.project_id
  region  = var.region
  name    = "${var.service_name}-autoscaler"
  target  = google_compute_region_instance_group_manager.instance_group.self_link

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60
    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_region_backend_service" "backend_service" {
  project               = var.project_id
  region                = var.region
  name                  = "${var.service_name}-backend-service"
  load_balancing_scheme = "INTERNAL"
  protocol              = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.instance_group.instance_group
  }

  health_checks = [google_compute_health_check.healtcheck.id]
}