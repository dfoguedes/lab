resource "google_compute_instance" "default" {
  name         = "vm-b"
  project      = var.project_id_b
  machine_type = "e2-micro"
  zone         = var.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }


  network_interface {
    network = google_compute_network.vpc_network_b.name
    access_config {
      # Ephemeral IP
    }

  }
}
