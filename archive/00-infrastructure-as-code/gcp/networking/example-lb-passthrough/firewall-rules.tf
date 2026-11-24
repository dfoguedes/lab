resource "google_compute_firewall" "allow_ssh_fwrule" {
  name    = "allow-ssh-fwrule"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [google_compute_subnetwork.subnetwork.ip_cidr_range]
}

# Allow SSH from Web Console
resource "google_compute_firewall" "allow_ssh_ciap_fwrule" {
  name    = "allow-ssh-ciap-fwrule"
  network = google_compute_network.vpc_network.name
  project = "gcp-network-452116"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # test only
}

# Allow icmp in the same network 
resource "google_compute_firewall" "allow_icmp_fwrule" {
  name    = "allow-icmp-fwrule"
  network = google_compute_network.vpc_network.name
  project = local.project

  allow {
    protocol = "icmp"
  }
  source_ranges = [google_compute_subnetwork.subnetwork.ip_cidr_range]
}


# allow access from health check ranges
resource "google_compute_firewall" "allow_lb_health_checks" {
  project       = local.project
  name          = "l7-xlb-fwrule"
  provider      = google
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

# allow communication within the subnet 
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name     = "ilb-to-backends"
  provider = google-beta
  project  = local.project

  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.name
  source_ranges = [google_compute_subnetwork.subnetwork.ip_cidr_range]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}
