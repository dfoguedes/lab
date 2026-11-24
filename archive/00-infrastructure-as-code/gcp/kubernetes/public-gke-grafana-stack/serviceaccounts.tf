# ---------------------------------------------------------------------------------------------------------------------
# Create service accounts
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "gke-sa" {
  account_id   = "sa-gke"
  display_name = "GKE Service Account"
  description  = "Service account for GKE Cluster"
}
