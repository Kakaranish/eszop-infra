locals {
  dns_zone = "eszop-dns-zone"
}

resource "google_compute_instance_template" "compute_instance_template" {
  project      = var.project_id
  region       = var.region
  name         = "${var.service_name}-cit"
  machine_type = var.machine_type

  metadata = var.metadata

  network_interface {
    network = "default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
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

resource "google_compute_health_check" "healthcheck" {
  project = var.project_id
  name    = "${var.service_name}-healthcheck"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 5
  unhealthy_threshold = 10


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
    health_check      = google_compute_health_check.healthcheck.id
    initial_delay_sec = 30
  }

  lifecycle {
    create_before_destroy = true
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    instance_redistribution_type = "PROACTIVE"
    max_surge_fixed              = 3
    min_ready_sec                = 30
  }

  version {
    instance_template = google_compute_instance_template.compute_instance_template.self_link
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
  name                  = "${var.service_name}-region-backend-service"
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_region_instance_group_manager.instance_group.instance_group
  }

  health_checks = [google_compute_health_check.healthcheck.id]
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  name          = "${var.service_name}-fwd-rule"
  service_label = var.service_name
  region        = var.region
  project       = var.project_id

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  all_ports             = true
  allow_global_access   = true
}

data "google_dns_managed_zone" "dns_zone" {
  name = local.dns_zone
}

resource "google_dns_record_set" "a" {
  name         = "${var.service_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_forwarding_rule.forwarding_rule.ip_address]
}

output "backend_id" {
  value = google_compute_region_backend_service.backend_service.id
}

output "healthcheck_id" {
  value = google_compute_health_check.healthcheck.id
}

output "instance_group" {
  value = google_compute_region_instance_group_manager.instance_group.instance_group
}
