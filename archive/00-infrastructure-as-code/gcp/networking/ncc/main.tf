resource "google_network_connectivity_hub" "hub" {
  name        = "star"
  description = "A sample star hub"
  labels = {
    hub = "star"
  }
  preset_topology = "STAR"
}

# =================== HUB Configurations ==============================
resource "google_compute_network" "vpc_hub" {
  name                    = "vpc-hub"
  auto_create_subnetworks = false
}
resource "google_network_connectivity_spoke" "spoke_hub" {
  name     = "spoke-hub-connection"
  hub      = google_network_connectivity_hub.hub.name
  location = "global"
  linked_vpc_network {
    uri = google_compute_network.vpc_hub.self_link
  }
  group = google_network_connectivity_group.ncc_group.id
}

resource "google_compute_firewall" "allow_ssh_iap_hub" {
  name    = "allow-ssh-via-iap-hub"
  network = google_compute_network.vpc_hub.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}
resource "google_compute_subnetwork" "vpc_subnet_hub" {
  name          = "sb-hub"
  network       = google_compute_network.vpc_hub.name
  ip_cidr_range = "10.0.2.0/24"
  depends_on    = [google_compute_network.vpc_hub]
}
resource "google_compute_firewall" "allow_icmp_hub" {
  name    = "allow-icmp-hub"
  network = google_compute_network.vpc_hub.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
resource "google_compute_firewall" "allow_internal_hub" {
  name    = "allow-internal-hub"
  network = google_compute_network.vpc_hub.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
# ============= END HUB CONFIGURATIONS ============================= 
# ============= Cloud Nat ============================= 

resource "google_compute_router" "router" {
  name    = "router01"
  region  = var.region
  network = google_compute_network.vpc_hub.name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "cn_router" {
  name                               = "cn-router"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
# ================= END Cloud NAT ===================================

resource "google_compute_instance" "hub_vm" {
  name           = "hub-vm"
  machine_type   = "e2-micro"
  zone           = "${var.region}-a"
  can_ip_forward = true

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    
    # Configure iptables MASQUERADE for NAT
    iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
    
    # Make iptables rules persistent
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
  EOF

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_hub.name
    subnetwork = google_compute_subnetwork.vpc_subnet_hub.name
  }
  network_interface {
    network    = google_compute_network.vpc_spoke1.name
    subnetwork = google_compute_subnetwork.subnet_spoke1.name
  }

}

# Spoke1
resource "google_compute_network" "vpc_spoke1" {
  name                    = "vpc-spoke1"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_spoke1" {
  name          = "sb-spoke1"
  network       = google_compute_network.vpc_spoke1.name
  ip_cidr_range = "10.0.0.0/24"
  depends_on    = [google_compute_network.vpc_spoke1]
}

resource "google_network_connectivity_spoke" "spoke1" {
  name     = "spoke1"
  hub      = google_network_connectivity_hub.hub.name
  location = "global"
  linked_vpc_network {
    uri = google_compute_network.vpc_spoke1.self_link
  }

  group = google_network_connectivity_group.ncc_group.id
}

# Spoke 2
resource "google_compute_network" "vpc_spoke2" {
  name                    = "vpc-spoke2"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_spoke2" {
  name          = "sb-spoke2"
  network       = google_compute_network.vpc_spoke2.name
  ip_cidr_range = "10.0.1.0/24"
  depends_on    = [google_compute_network.vpc_spoke2]
}
# Groups helps manage the spokes and apply policies to them
resource "google_network_connectivity_group" "ncc_group" {
  hub         = google_network_connectivity_hub.hub.name
  name        = "center"
  description = "center hub group"
  auto_accept {
    auto_accept_projects = [
      var.project_id
    ]
  }
}
resource "google_network_connectivity_spoke" "spoke2" {
  name     = "spoke2"
  hub      = google_network_connectivity_hub.hub.name
  location = "global"
  linked_vpc_network {
    uri = google_compute_network.vpc_spoke2.self_link
  }
  group = google_network_connectivity_group.ncc_group.id
}

# ========= VMS AND FIREWALLS FOR TESTING ==========

resource "google_compute_instance" "linux_vm_spoke1" {
  name         = "linux-vm-spoke1"
  machine_type = "e2-micro"
  tags         = ["use-nva"]
  network_interface {
    network    = google_compute_network.vpc_spoke1.name
    subnetwork = google_compute_subnetwork.subnet_spoke1.name
  }
  zone = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = {
        spoke = "spoke1"
      }
    }
  }
}

resource "google_compute_firewall" "allow_ssh_iap_spoke1" {
  name    = "allow-ssh-via-iap"
  network = google_compute_network.vpc_spoke1.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_icmp_spoke1" {
  name    = "allow-icmp-spoke1"
  network = google_compute_network.vpc_spoke1.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "allow_internal_spoke1" {
  name    = "allow-internal-spoke1"
  network = google_compute_network.vpc_spoke1.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "allow_ssh_iap_spoke2" {
  name    = "allow-ssh-via-iap-spoke2"
  network = google_compute_network.vpc_spoke2.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_icmp_spoke2" {
  name    = "allow-icmp-spoke2"
  network = google_compute_network.vpc_spoke2.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "allow_internal_spoke2" {
  name    = "allow-internal-spoke2"
  network = google_compute_network.vpc_spoke2.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_instance" "linux_vm_spoke2" {
  name         = "linux-vm-spoke2"
  machine_type = "e2-micro"
  network_interface {
    network    = google_compute_network.vpc_spoke2.name
    subnetwork = google_compute_subnetwork.subnet_spoke2.name
  }
  zone = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = {
        spoke = "spoke2"
      }
    }
  }
}

# ====================== ROUTES ======================

resource "google_compute_route" "from_spoke1_to_internet" {
  name                   = "route-spoke1-to-internet"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.vpc_spoke1.self_link
  priority               = 100
  tags                   = ["use-nva"]
  next_hop_instance      = google_compute_instance.hub_vm.self_link
  next_hop_instance_zone = "${var.region}-a"
}
