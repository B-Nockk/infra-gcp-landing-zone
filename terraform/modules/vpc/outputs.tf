# terraform/modules/network/outputs.tf

# ============================== ==============================
# VPC Outputs
# ============================== ==============================
output "vpc_ids" {
  description = "Map of VPC names to their self_links (IDs)."
  value       = { for k, v in google_compute_network.this : k => v.id }
}

output "vpc_names" {
  description = "Map of VPC keys to their actual GCP names."
  value       = { for k, v in google_compute_network.this : k => v.name }
}

# ============================== ==============================
# Subnet Outputs
# ============================== ==============================
output "subnet_ids" {
  description = "Map of subnet keys to their self_links (IDs). Used by Compute/GKE to attach VMs."
  # The resource's own for_each keys already match "vpc_key-subnet_key" — no need
  # to re-flatten var.vpcs a second time just to rebuild the same keys.
  value = { for k, v in google_compute_subnetwork.this : k => v.id }
}

output "subnet_self_links" {
  description = "Map of subnet keys to their self_links."
  value       = { for k, v in google_compute_subnetwork.this : k => v.self_link }
}

# ============================== ==============================
# Security & Routing Outputs
# ============================== ==============================
output "firewall_rule_names" {
  description = "List of created firewall rule names (useful for debugging and documentation)."
  value       = [for fw in google_compute_firewall.this : fw.name]
}
