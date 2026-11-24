
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.1.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.1.0"
    }
  }
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Node01 
resource "google_compute_network" "vpc_node01" {
  name                    = "vpc-node01"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_node01" {
  name          = "sb-node01"
  network       = google_compute_network.vpc_node01.name
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"
  depends_on    = [google_compute_network.vpc_node01]
}
# resource "google_compute_address" "psc_endpoint_ip" {
#   name         = "psc-endpoint-consumer-ip"
#   subnetwork   = google_compute_subnetwork.subnet_node01.id
#   address_type = "INTERNAL"
#   region       = var.region
# }
# resource "google_compute_forwarding_rule" "fr_consumer_psc" {
#   name                    = "fr-consumer-psc"
#   allow_psc_global_access = true
#   load_balancing_scheme   = ""
#   region                  = var.region
#   target                  = google_compute_service_attachment.psc_publisher.id
#   network                 = google_compute_network.vpc_node01.id
#   subnetwork              = google_compute_subnetwork.subnet_node01.id
#   ip_address              = google_compute_address.psc_endpoint_ip.id
# }

# Node02
resource "google_compute_network" "vpc_node02" {
  name                    = "vpc-node02"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_node02" {
  name          = "sb-node02"
  network       = google_compute_network.vpc_node02.name
  region        = var.region
  ip_cidr_range = "10.0.1.0/24"
  depends_on    = [google_compute_network.vpc_node02]
}
