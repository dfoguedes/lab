
# MIG
resource "google_compute_instance_group_manager" "default" {
  project  = local.project
  name     = "mig"
  provider = google
  zone     = local.zone

  named_port {
    name = "http"
    port = 80

  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 1
}

# backend service with custom request and response headers
# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "backend-service"
  project               = local.project
  provider              = google-beta
  protocol              = "TCP"
  region                = local.region
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group          = google_compute_instance_group_manager.default.instance_group
    balancing_mode = "CONNECTION"
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  project      = local.project
  name         = "mig-template"
  provider     = google
  machine_type = "e2-small"
  tags         = ["allow-health-check"]

  network_interface {
    network            = google_compute_network.vpc_network.name
    subnetwork         = google_compute_subnetwork.subnetwork.name
    subnetwork_project = local.project
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata_startup_script = file("../../scripts/startup-script.sh")
  lifecycle {
    create_before_destroy = true
  }
}
