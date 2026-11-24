# ---------------------------------------------------------------------------------------------------------------------
# Create network VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "vpc_network" {
  name                    = "${local.env}-vpc-network"
  description             = "VPC network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = local.project

}

# ---------------------------------------------------------------------------------------------------------------------
# Create private subnetwork
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  name          = "${local.env}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = local.region
  network       = google_compute_network.vpc_network.name
  project       = local.project

  private_ip_google_access = true
}


# test instance
resource "google_compute_instance" "vm_test" {
  name         = "l4-ilb-test-vm"
  provider     = google-beta
  machine_type = "e2-small"
  zone         = "${local.region}-a"
  project      = local.project
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnetwork.id
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
}
