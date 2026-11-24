# ---------------------------------------------------------------------------------------------------------------------
# Compute project metadata
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_project_metadata_item" "enableos_login" {
  key   = "enable-oslogin"
  value = "TRUE"
}

resource "google_compute_instance" "bastion_host" {
  name         = "${local.env}-compute-instance"
  machine_type = "e2-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnetwork.name

  }
  metadata_startup_script = file("../scripts/kubernetes_utils.sh")

}

