# ---------------------------------------------------------------------------------------------------------------------
# Parameters 
# ---------------------------------------------------------------------------------------------------------------------
variable "env" {
  description = "List of environments"
  type = map(object({
    project = string,
    region  = string,
    zone    = string,
    network = string,
  }))
}

# ---------------------------------------------------------------------------------------------------------------------
# Local variables
# ---------------------------------------------------------------------------------------------------------------------

locals {

  region  = var.env[terraform.workspace].region
  zone    = var.env[terraform.workspace].zone
  project = var.env[terraform.workspace].project
  env     = terraform.workspace
  network = var.env[terraform.workspace].network

}

