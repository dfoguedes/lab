
resource "google_compute_global_address" "private_ip_address" {
  count         = local.create-sql ? 1 : 0
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.0.name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = local.create-sql ? 1 : 0
  network                 = google_compute_network.vpc_network.0.name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.0.name]
}

resource "random_id" "db_name_suffix" {
  count       = local.create-sql ? 1 : 0
  byte_length = 4
}

resource "google_sql_database_instance" "this" {
  count               = local.create-sql ? 1 : 0
  name                = "private-instance-${random_id.db_name_suffix.0.hex}"
  region              = local.region
  database_version    = "MYSQL_8_0"
  project             = local.project
  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.0.id
      enable_private_path_for_google_cloud_services = true
    }
  }
}
