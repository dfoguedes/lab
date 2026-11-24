resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc_node01.name
  region  = var.region
}

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 5.0"
  project_id = var.project_id
  region     = var.region
  router     = google_compute_router.router.name
}
