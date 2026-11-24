
resource "google_container_cluster" "public_gke_cluster" {
  name                     = "test-cluster"
  location                 = var.region
  network                  = google_compute_network.vpc_network.name
  subnetwork               = google_compute_subnetwork.subnetwork.name
  remove_default_node_pool = true
  deletion_protection      = false

  # Configure Pod and Service CIDR ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "subnet-gke-pods"
    services_secondary_range_name = "subnet-gke-services"
  }
  master_authorized_networks_config {
    # Kubernetes master nodes are acessible from the public internet
    gcp_public_cidrs_access_enabled = true
  }
  # configuration options for the release channel feature, which provide more control over automatic upgrades of your gke clusters.
  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
}



resource "google_container_node_pool" "nodepool" {
  location          = local.region
  cluster           = google_container_cluster.public_gke_cluster.name
  project           = local.project
  name              = "public-nodepool"
  max_pods_per_node = 32
  node_count        = 1

  node_config {
    machine_type    = "e2-micro"
    disk_type       = "pd-standard"
    disk_size_gb    = "30"
    service_account = google_service_account.gke-sa.name
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    total_min_node_count = 1
    total_max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 1
  }
}
