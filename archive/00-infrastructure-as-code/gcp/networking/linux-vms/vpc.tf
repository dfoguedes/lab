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

# Node02
# resource "google_compute_network" "vpc_node02" {
#   name                    = "vpc-node02"
#   auto_create_subnetworks = false
# }
# resource "google_compute_subnetwork" "subnet_node02" {
#   name          = "sb-node02"
#   network       = google_compute_network.vpc_node02.name
#   region        = var.region
#   ip_cidr_range = "10.0.1.0/24"
#   depends_on    = [google_compute_network.vpc_node02]
# }
