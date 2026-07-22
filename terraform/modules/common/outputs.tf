# terraform/modules/common/outputs.tf

output "common_tags" {
  description = "Standard labels applied to all GCP resources."
  value       = local.common_tags
}

output "resource_identifier" {
  description = "Standard resource identifier (63-char safe). e.g., lndzn-dev-euw1-01"
  value       = local.resource_identifier
}

output "gcp_regions" {
  description = "Region mapping (full API name to short token)."
  value       = local.gcp_regions
}

output "resource_computed_names" {
  description = "Enterprise naming catalogue for GCP resources — the single source of truth every other module reads names from."
  value       = local.resource_computed_names
}

output "separators" {
  description = "Centralized separator characters for naming joins."
  value       = local.sep
}
