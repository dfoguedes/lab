provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "vpn-gateway-static-ip"
  region = "us-central1"
}

resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = "vpn-gateway"
  network = google_compute_network.vpc_network.self_link
  region  = "us-central1"
}

resource "google_compute_vpn_tunnel" "vpn_tunnel_1" {
  name                    = "vpn-tunnel-1"
  target_vpn_gateway      = google_compute_vpn_gateway.vpn_gateway.self_link
  peer_ip                 = "85.240.240.153"
  shared_secret           = var.shared_secret
  ike_version             = 2
  local_traffic_selector  = ["10.0.0.0/24"]      # Local subnet range
  remote_traffic_selector = ["192.168.124.0/24"] # On-premises subnet range
  region                  = "us-central1"

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500
  ]
}


// First forwarding rule - use the reserved static IP
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  region      = google_compute_vpn_gateway.vpn_gateway.region
}

// Second forwarding rule - use the reserved static IP
resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  region      = google_compute_vpn_gateway.vpn_gateway.region
}

// Third forwarding rule - use the reserved static IP
resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  region      = google_compute_vpn_gateway.vpn_gateway.region
}
