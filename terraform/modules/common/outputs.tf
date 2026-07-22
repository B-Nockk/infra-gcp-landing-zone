# terraform/modules/common/outputs.tf

output "common_tags" {
  description = "Standard labels applied to all GCP resources."
  value       = local.common_tags
}

output "resource_identifier" {
  description = "Standard resource identifier (63-char safe). e.g., lndzn-dev-euw1-01"
  value       = local.resource_identifier
}

# output "safe_short_id" {
#   description = "Truncated identifier for 30-char constrained resources (Project ID, SA). e.g., lndzn-dev-euw1"
#   value       = local.safe_short_id
# }

output "gcp_regions" {
  description = "Region mapping (full API name to short token)."
  value       = local.gcp_regions
}

output "resource_computed_names" {
  description = "Enterprise naming catalogue for GCP resources."
  value       = local.resource_computed_names
}

output "resource_computed_names" {
  description = "Enterprise naming catalogue for GCP resources."
  value       = local.resource_computed_names
}

output "iam_prefix" {
  description = "GCP resource naming abbreviations."
  value       = local.resource_computed_names.iam_prefix
}

output "separators" {
  description = "Centralized separator characters for naming joins."
  value       = local.sep
}
