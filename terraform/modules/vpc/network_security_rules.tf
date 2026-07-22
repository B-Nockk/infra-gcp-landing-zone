# terraform/modules/network/network_security_rules.tf

# ============================== ==============================
# Firewall Rules (VPC-Level)
# ============================== ==============================
resource "google_compute_firewall" "this" {
  for_each = local.flattened_firewalls

  # Was hardcoded as "fw-${each.key}" — now pulls the token + identifier from
  # common, same pattern the route resource below already used correctly.
  name    = "${var.resource_computed_names.vpcs[each.value.vpc_key].firewall_prefix}-${each.value.fw_key}"
  project = var.project_id
  network = google_compute_network.this[each.value.vpc_key].name

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
