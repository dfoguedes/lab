resource "google_compute_network" "vpc_network_a" {
  project                                   = var.project_id_a
  name                                      = "vpc-a"
  auto_create_subnetworks                   = true
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}

resource "google_compute_network" "vpc_network_b" {
  project                                   = var.project_id_b
  name                                      = "vpc-b"
  auto_create_subnetworks                   = true
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}
# Allow SSH from Web Console
resource "google_compute_firewall" "allow_ssh_ciap_fwrule" {
  name    = "allow-ssh-ciap-fwrule"
  network = google_compute_network.vpc_network_b.name
  project = var.project_id_b

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # test only
}

# resource "google_compute_subnetwork" "vpc_b_subnet_for_psc" {
#   name          = "vpc-b-psc-subnet"
#   ip_cidr_range = "10.128.0.0/20" // Example CIDR, adjust if needed
#   region        = var.region      // Ensure this is the region for VPC B resources
#   network       = google_compute_network.vpc_network_b.self_link
#   project       = var.project_id_b
# }
