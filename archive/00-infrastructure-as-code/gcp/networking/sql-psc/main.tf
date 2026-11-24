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
  project = var.project_id_a
  region  = var.region
  zone    = var.zone
}

