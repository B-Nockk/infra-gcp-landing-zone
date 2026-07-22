# terraform/modules/compute/outputs.tf

# ============================== ==============================
# Instance Template Outputs
# ============================== ==============================
output "instance_template_ids" {
  description = "Map of compute fleet keys to their Instance Template IDs."
  value       = { for k, v in google_compute_instance_template.this : k => v.id }
}

output "instance_template_self_links" {
  description = "Map of compute fleet keys to their Instance Template self_links."
  value       = { for k, v in google_compute_instance_template.this : k => v.self_link }
}

# ============================== ==============================
# Managed Instance Group (MIG) Outputs
# ============================== ==============================
output "instance_group_manager_ids" {
  description = "Map of compute fleet keys to their MIG IDs."
  value       = { for k, v in google_compute_region_instance_group_manager.this : k => v.id }
}

output "instance_group_self_links" {
  description = "Map of compute fleet keys to their MIG self_links. (Crucial for wiring to Load Balancer Backend Services)."
  value       = { for k, v in google_compute_region_instance_group_manager.this : k => v.self_link }
}

# ============================== ==============================
# Health Check Outputs
# ============================== ==============================
output "health_check_ids" {
  description = "Map of compute fleet keys to their Health Check IDs."
  value       = { for k, v in google_compute_health_check.this : k => v.id }
}

output "health_check_self_links" {
  description = "Map of compute fleet keys to their Health Check self_links."
  value       = { for k, v in google_compute_health_check.this : k => v.self_link }
}
