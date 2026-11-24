terraform {
  # This module has been updated with 0.13 syntax, which means it is no longer compatible with any versions below 0.13.
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.23.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.23.0"
    }
  }
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  service = each.key

  disable_on_destroy         = false
  disable_dependent_services = false
}


# --------------------------------------------------------------------------------------------------------------------- # Project iNformation
# Project information
# ---------------------------------------------------------------------------------------------------------------------
data "google_project" "project" {
  project_id = local.project
}

