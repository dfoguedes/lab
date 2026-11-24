# ---------------------------------------------------------------------------------------------------------------------
# Create network VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "vpc_network" {
  name                    = "${local.project}-vpc-network"
  description             = "VPC network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create private subnetwork
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${local.project}-subnet"
  ip_cidr_range            = "10.0.0.0/24" # 10.0.0.255
  region                   = local.region
  network                  = google_compute_network.vpc_network.name
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "subnet-gke-pods"
    ip_cidr_range = "10.1.0.0/16" # Secondary range for GKE pods (10.1.255.255)
  }
  secondary_ip_range {
    range_name    = "subnet-gke-services"
    ip_cidr_range = "10.2.0.0/20" # Secondary range for GKE services

  }
}
