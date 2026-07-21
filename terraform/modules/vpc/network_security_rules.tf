# terraform/modules/network/network_security_rules.tf

# ============================== ==============================
# Firewall Rules (VPC-Level)
# ============================== ==============================
resource "google_compute_firewall" "this" {
  # We need a nested loop: for_each over VPCs, then over the firewalls inside them
  for_each = merge([
    for vpc_key, vpc_config in var.vpcs : {
      for fw_key, fw_config in vpc_config.firewall_rules :
      "${vpc_key}-${fw_key}" => merge(fw_config, { vpc_name = google_compute_network.this[vpc_key].name })
    }
  ]...)

  name    = "fw-${each.key}"
  project = var.project_id
  network = each.value.vpc_name

  priority  = each.value.priority
  direction = each.value.direction

  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.rules : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.rules : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags
}
