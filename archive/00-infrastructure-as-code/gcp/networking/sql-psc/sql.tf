resource "google_sql_database_instance" "main" {
  name                = "psc-instance"
  database_version    = "MYSQL_8_0"
  project             = var.project_id_a
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = ["project-b-459609"]
      }
      ipv4_enabled = false
    }
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
    availability_type = "REGIONAL"
  }
}



resource "google_compute_address" "default" {
  name         = "psc-compute-address-${google_sql_database_instance.main.name}"
  region       = var.region
  project      = var.project_id_b
  address_type = "INTERNAL"
  subnetwork   = "vpc-b"
  address      = "10.164.0.5"
}


resource "google_compute_forwarding_rule" "default" {
  project               = var.project_id_b
  name                  = "psc-forwarding-rule-${google_sql_database_instance.main.name}"
  region                = var.region
  network               = google_compute_network.vpc_network_b.name
  ip_address            = google_compute_address.default.self_link
  load_balancing_scheme = ""
  target                = google_sql_database_instance.main.psc_service_attachment_link
}
