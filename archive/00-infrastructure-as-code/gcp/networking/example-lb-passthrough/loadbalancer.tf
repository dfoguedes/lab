

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "ilb-forwarding-rule"
  project               = local.project
  backend_service       = google_compute_region_backend_service.default.id
  provider              = google-beta
  region                = local.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = google_compute_network.vpc_network.name
  subnetwork            = google_compute_subnetwork.subnetwork.name

}
# health check
resource "google_compute_health_check" "default" {
  project  = local.project
  name     = "ilb-hc"
  provider = google
  http_health_check {
    port_specification = "USE_NAMED_PORT"
    port_name          = "http"
  }
}
