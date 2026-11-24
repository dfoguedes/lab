
# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  count                 = local.create-mig ? 1 : 0
  project               = local.project
  name                  = "l7-xlb-forwarding-rule"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.0.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  count    = local.create-mig ? 1 : 0
  project  = local.project
  name     = "l7-xlb-target-http-proxy"
  provider = google-beta
  url_map  = google_compute_url_map.default.0.id
}

# url map
resource "google_compute_url_map" "default" {
  count           = local.create-mig ? 1 : 0
  project         = local.project
  name            = "l7-xlb-url-map"
  provider        = google-beta
  default_service = google_compute_backend_service.default.0.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher"
  }
  path_matcher {
    name            = "path-matcher"
    default_service = google_compute_backend_service.default.0.id
    path_rule {
      service = google_compute_backend_service.default.0.id
      paths   = ["/test/*"]
    }
  }
}

# health check
resource "google_compute_health_check" "default" {
  count    = local.create-mig ? 1 : 0
  project  = local.project
  name     = "l7-xlb-hc"
  provider = google
  http_health_check {
    port_specification = "USE_NAMED_PORT"
    port_name          = "http"
  }
}
