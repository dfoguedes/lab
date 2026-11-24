locals {
  project   = var.project
  region    = var.region
  create-lb = var.create-lb == true ? true : false
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Region name"
  type        = string
}

variable "create-lb" {
  description = "Create load balancer"
  type        = bool
  default     = false
}
