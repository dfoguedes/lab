# LOAD BALANCER

# resource "google_compute_subnetwork" "psc_nat_sb" {
#   name          = "consumer-psc-sb"
#   ip_cidr_range = "10.10.0.0/24"
#   region        = var.region
#   network       = google_compute_network.vpc_node02.id
#   purpose       = "PRIVATE_SERVICE_CONNECT"
# }
# resource "google_compute_service_attachment" "psc_publisher" {
#   name                  = "psc-publisher"
#   nat_subnets           = [google_compute_subnetwork.psc_nat_sb.id]
#   region                = var.region
#   connection_preference = "ACCEPT_AUTOMATIC"
#   target_service        = google_compute_forwarding_rule.google_compute_forwarding_rule.id
#   enable_proxy_protocol = false

# }

# resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
#   name                  = "l7-ilb-forwarding-rule"
#   region                = var.region
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   port_range            = "80"
#   allow_global_access   = true
#   network               = google_compute_network.vpc_node02.id
#   subnetwork            = google_compute_subnetwork.subnet_node02.id

#   target = google_compute_region_target_http_proxy.default.id
# }
# resource "google_compute_region_url_map" "default" {
#   name            = "l7-ilb-url-map"
#   region          = var.region
#   default_service = google_compute_region_backend_service.default.id
# }
# resource "google_compute_subnetwork" "proxy_only_subnet" {
#   name          = "proxy-only-subnet"
#   ip_cidr_range = "10.129.0.0/23"
#   network       = google_compute_network.vpc_node02.id
#   region        = var.region
#   purpose       = "REGIONAL_MANAGED_PROXY"
#   role          = "ACTIVE"
# }

# resource "google_compute_region_target_http_proxy" "default" {
#   name    = "l7-ilb-target-proxy"
#   region  = var.region
#   url_map = google_compute_region_url_map.default.id
# }
# resource "google_compute_region_backend_service" "default" {
#   name                  = "l4-ilb-backend-subnet"
#   provider              = google-beta
#   project               = var.project_id
#   region                = var.region
#   protocol              = "HTTP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   security_policy       = google_compute_region_security_policy.armor_internal.self_link
#   port_name             = "http"
#   backend {
#     group           = google_compute_region_instance_group_manager.mig.instance_group
#     balancing_mode  = "UTILIZATION"
#     max_utilization = 0.8
#     capacity_scaler = 1.0
#   }

#   health_checks = [google_compute_region_health_check.default.id]
# }

# resource "google_compute_instance_template" "instance_template" {
#   name         = "l4-ilb-mig-template"
#   machine_type = "e2-small"
#   tags         = ["allow-ssh", "allow-health-check", "allow-http"]

#   network_interface {
#     network    = google_compute_network.vpc_node02.id
#     subnetwork = google_compute_subnetwork.subnet_node02.id
#     # access_config {
#     #   # add external ip to fetch packages
#     # }
#   }
#   disk {
#     source_image = "ubuntu-os-cloud/ubuntu-2204-lts"
#     auto_delete  = true
#     boot         = true
#   }

#   # install nginx and serve a simple web page
#   metadata = {
#     startup-script = <<-EOF1
#       #! /bin/bash
#       set -euo pipefail

#       export DEBIAN_FRONTEND=noninteractive
#       apt-get update
#       apt-get install -y nginx-light jq

#       cat <<EOF > /var/www/html/index.html
#       <pre>
#       NGINX is working like a charm :)
#       </pre>
#       EOF
#     EOF1
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "google_compute_firewall" "fw_http" {

#   name    = "fw-allow-http"
#   network = google_compute_network.vpc_node02.id
#   allow {
#     ports    = ["80"]
#     protocol = "TCP"
#   }
#   source_ranges = ["10.0.1.0/24"]
#   target_tags   = ["allow-http"]
# }

# resource "google_compute_region_health_check" "default" {
#   name   = "l4-ilb-hc"
#   region = var.region
#   http_health_check {
#     port = "80"
#   }
# }

# resource "google_compute_region_instance_group_manager" "mig" {
#   name   = "l4-ilb-mig1"
#   region = var.region
#   version {
#     instance_template = google_compute_instance_template.instance_template.id
#     name              = "primary"
#   }
#   named_port {
#     name = "http"
#     port = 80
#   }
#   base_instance_name = "vm"
#   target_size        = 1
# }

# # allow access from the VMs to the proxy subnet
# resource "google_compute_firewall" "allow_proxy_to_vms" {
#   name          = "allow-proxy-only-subnet-to-vms"
#   network       = google_compute_network.vpc_node02.id
#   source_ranges = ["10.129.0.0/23"]
#   target_tags   = ["allow-http"]

#   allow {
#     protocol = "tcp"
#     ports    = ["80"]
#   }
# }
# # allow all access from health check ranges
# resource "google_compute_firewall" "fw_hc" {
#   name          = "l4-ilb-fw-allow-hc"
#   direction     = "INGRESS"
#   network       = google_compute_network.vpc_node02.id
#   source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
#   allow {
#     protocol = "tcp"
#   }
#   target_tags = ["allow-health-check"]
# }

# # Cloud nat
# resource "google_compute_router" "router" {
#   name    = "nat-router"
#   network = google_compute_network.vpc_node02.id
#   region  = var.region
# }
# module "cloud_nat" {
#   source     = "terraform-google-modules/cloud-nat/google"
#   version    = "~> 5.0"
#   project_id = var.project_id
#   region     = var.region
#   router     = google_compute_router.router.name
# }
