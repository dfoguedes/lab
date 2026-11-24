locals {
  deny_ips  = ["0.0.0.0/0"]
  allow_ips = ["85.240.240.153/32"]
}

resource "google_compute_security_policy" "this" {
  name = "lb-policy"

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

  dynamic "rule" {
    for_each = toset(local.deny_ips)
    content {
      action   = "deny(403)"
      priority = "5000"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [rule.value]
        }
      }
      description = "Deny access to IPs in ${rule.value}"
    }
  }
  dynamic "rule" {
    for_each = toset(local.allow_ips)
    content {
      action   = "allow"
      priority = "1000"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [rule.value]
        }
      }
      description = "Allow access to IPs in ${rule.value}"
    }
  }

}
