
# # Cloud armor

# resource "google_compute_region_security_policy" "armor_internal" {
#   name     = "armor-policy-internal"
#   provider = google-beta
#   region   = var.region
#   project  = var.project_id
#   type     = "CLOUD_ARMOR"

# }

# resource "google_compute_region_security_policy_rule" "deny_node01" {
#   provider        = google-beta
#   project         = var.project_id
#   region          = var.region
#   security_policy = google_compute_region_security_policy.armor_internal.name
#   priority        = 1000
#   match {
#     versioned_expr = "SRC_IPS_V1"
#     config {
#       src_ip_ranges = ["10.0.1.0/24"] # Range da subnet-node02
#     }
#   }
#   action = "deny(403)"
# }
