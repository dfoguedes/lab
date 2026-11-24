# ---------------------------------------------------------------------------------------------------------------------
# Create network VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "vpc_network" {
  count                   = local.create-network ? 1 : 0
  name                    = "${local.env}-vpc-network"
  description             = "VPC network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create private subnetwork
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  count                    = local.create-network ? 1 : 0
  name                     = "${local.env}-subnet"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = local.region
  network                  = google_compute_network.vpc_network.0.name
  private_ip_google_access = true
}
