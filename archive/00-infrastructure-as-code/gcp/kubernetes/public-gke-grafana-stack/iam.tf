
resource "google_service_account_iam_member" "gke-sa-workload-identity-user" {
  service_account_id = google_service_account.gke-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project}.svc.id.goog/gke-sa]"
}
