resource "google_compute_firewall" "allow_ssh_fwrule" {
  count   = local.create-network ? 1 : 0
  name    = "allow-ssh-fwrule"
  network = google_compute_network.vpc_network.0.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [google_compute_subnetwork.subnetwork.0.ip_cidr_range]
}

# Allow SSH from Web Console
resource "google_compute_firewall" "allow_ssh_ciap_fwrule" {
  count   = local.create-network ? 1 : 0
  name    = "allow-ssh-ciap-fwrule"
  network = google_compute_network.vpc_network.0.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

# Allow icmp in the same network 
resource "google_compute_firewall" "allow_icmp_fwrule" {
  count   = local.create-network ? 1 : 0
  name    = "allow-icmp-fwrule"
  network = google_compute_network.vpc_network.0.name
  allow {
    protocol = "icmp"
  }
  source_ranges = [google_compute_subnetwork.subnetwork.0.ip_cidr_range]
}


# allow access from health check ranges
resource "google_compute_firewall" "default" {
  count         = local.create-mig ? 1 : 0
  project       = local.project
  name          = "l7-xlb-fwrule"
  provider      = google
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.0.name
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

