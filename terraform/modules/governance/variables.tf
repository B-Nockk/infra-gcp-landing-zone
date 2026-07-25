# terraform/modules/governance/variables.tf
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "org_policies" {
  description = "Data-driven map of GCP Organization Policies to enforce."
  type = map(object({
    enforce = bool
  }))

  # Fail-fast: No defaults. The engineer must explicitly declare policies in tfvars.
}

variable "vpc_service_controls" {
  description = "Optional VPC Service Controls configuration. Requires an Organization ID."
  type = object({
    org_id               = string
    perimeter_name       = string
    restricted_services  = list(string)
    restricted_resources = list(string) # e.g., GCS buckets, BigQuery datasets
  })
  default = null # If null, the module skips VPC SC creation entirely.
}

# TODO:: Remove if not used
variable "allowed_resource_locations" {
  description = "List of allowed resource locations (e.g., 'in:eu-locations')."
  type        = list(string)
  default     = ["in:eu-locations"]
}
