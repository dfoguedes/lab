
# MIG
resource "google_compute_instance_group_manager" "default" {
  count    = local.create-mig ? 1 : 0
  project  = local.project
  name     = "l7-xlb-mig1"
  provider = google
  zone     = local.zone

  named_port {
    name = "http"
    port = 80

  }
  version {
    instance_template = google_compute_instance_template.default.0.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 1
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  count                 = local.create-mig ? 1 : 0
  project               = local.project
  name                  = "l7-xlb-backend-service"
  security_policy       = google_compute_security_policy.this.id
  provider              = google
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = false
  health_checks         = [google_compute_health_check.default.0.id]
  backend {
    group           = google_compute_instance_group_manager.default.0.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0

  }
}

# instance template
resource "google_compute_instance_template" "default" {
  count        = local.create-mig ? 1 : 0
  project      = local.project
  name         = "l7-xlb-mig-template"
  provider     = google
  machine_type = "e2-small"
  tags         = ["allow-health-check"]

  network_interface {
    network            = google_compute_network.vpc_network.0.name
    subnetwork         = google_compute_subnetwork.subnetwork.0.name
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
