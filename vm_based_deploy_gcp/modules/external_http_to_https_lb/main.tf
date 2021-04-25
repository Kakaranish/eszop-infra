data "google_compute_global_address" "external_lb_address" {
  name = "external-lb-ip"
}

resource "google_compute_target_http_proxy" "external_proxy" {
  name    = "external-proxy"
  url_map = google_compute_url_map.external_url_map.id
}


resource "google_compute_url_map" "external_url_map" {
  name = "external-http-to-https-lb"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_global_forwarding_rule" "external_lb_fwd_rule" {
  name       = "external-http-to-https-fwd-rule"
  port_range = "80"
  ip_address = data.google_compute_global_address.external_lb_address.address
  target     = google_compute_target_http_proxy.external_proxy.id
}
