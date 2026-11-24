# ---------------------------------
# GKE Private cluster
# ---------------------------------

resource "google_container_cluster" "gke" {
  name                     = "${local.env}-gke-cluster"
  location                 = local.region
  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = google_compute_network.vpc_network.name
  subnetwork               = google_compute_subnetwork.subnetwork.name
  deletion_protection      = false
  master_authorized_networks_config {
  }
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
  }
  depends_on = [google_project_service.services]
}

resource "google_container_node_pool" "node_pool" {
  name       = "my-pool"
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

  }
}

