data "google_compute_global_address" "external_lb_address" {
  name = "external-lb-ip"
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name = "external-lb-cert"

  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_backend_service" "frontend_global_backend" {
  project               = var.project_id
  name                  = "frontend-global-backend-service"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group                 = var.frontend_service_mig
    balancing_mode        = "RATE"
    max_rate_per_instance = 1000
  }

  health_checks = [var.frontend_service_healthcheck_id]
}

resource "google_compute_backend_service" "gateway_global_backend" {
  project               = var.project_id
  name                  = "gateway-global-backend-service"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group                 = var.gateway_service_mig
    balancing_mode        = "RATE"
    max_rate_per_instance = 1000
  }

  health_checks = [var.gateway_service_healthcheck_id]
}

resource "google_compute_url_map" "external_url_map" {
  name = "external-https-lb"

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
  name       = "external-https-lb-fwd-rule"
  target     = google_compute_target_https_proxy.external_proxy.id
  port_range = "443"
  ip_address = data.google_compute_global_address.external_lb_address.address
}
