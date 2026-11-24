
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "europe-west1"
}
# ========= VMS AND FIREWALLS FOR TESTING ==========

resource "google_compute_instance" "linux_vm_node01" {
  name         = "linux-vm-node01"
  machine_type = "e2-micro"
  tags         = ["use-nva"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    # add GPG key
    curl -s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null
    FRRVER="frr-stable"
    echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
        $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
    # update and install FRR
    sudo apt update -y && sudo apt install -y frr frr-pythontools
    sed -i 's/^\(bgpd=no\)/\1\nbgpd=yes/' /etc/frr/daemons
    systemctl restart frr
  EOT
  network_interface {
    # access_config {}
    network    = google_compute_network.vpc_node01.name
    subnetwork = google_compute_subnetwork.subnet_node01.name
  }
  zone = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = {
        node = "node01"
      }
    }
  }

  depends_on = [google_compute_subnetwork.subnet_node01]
}

resource "google_compute_firewall" "allow_ssh_iap_node01" {
  name    = "allow-ssh-via-iap"
  network = google_compute_network.vpc_node01.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_icmp_node01" {
  name    = "allow-icmp-node01"
  network = google_compute_network.vpc_node01.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "allow_internal_node01" {
  name    = "allow-internal-node01"
  network = google_compute_network.vpc_node01.self_link

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




# # VM 2
# resource "google_compute_instance" "linux_vm_node02" {
#   name                    = "linux-vm-node02"
#   machine_type            = "e2-micro"
#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     apt-get update -y
#     # add GPG key
#     curl -s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null
#     FRRVER="frr-stable"
#     echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
#         $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
#     # update and install FRR
#     sudo apt update -y && sudo apt install -y frr frr-pythontools
#     sed -i 's/^\(bgpd=no\)/\1\nbgpd=yes/' /etc/frr/daemons
#     systemctl restart frr
#   EOT
#   network_interface {
#     access_config {
#     }
#     network    = google_compute_network.vpc_node02.name
#     subnetwork = google_compute_subnetwork.subnet_node02.name
#   }
#   zone = "${var.region}-a"
#   boot_disk {

#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-2204-lts"
#       labels = {
#         node = "node02"
#       }
#     }
#   }
#   depends_on = [google_compute_subnetwork.subnet_node02]
# }


# resource "google_compute_firewall" "allow_ssh_iap_node02" {
#   name    = "allow-ssh-via-iap-node02"
#   network = google_compute_network.vpc_node02.self_link

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["35.235.240.0/20"]
# }

# resource "google_compute_firewall" "allow_icmp_node02" {
#   name    = "allow-icmp-node02"
#   network = google_compute_network.vpc_node02.self_link

#   allow {
#     protocol = "icmp"
#   }

# }

# resource "google_compute_firewall" "allow_internal_node02" {
#   name    = "allow-internal-node02"
#   network = google_compute_network.vpc_node02.self_link

#   allow {
#     protocol = "tcp"
#     ports    = ["0-65535"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["0-65535"]
#   }

# }
