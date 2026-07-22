# terraform/modules/common/tags.tf

locals {
  # GCP Label Sanitizer Pattern:
  # 1. trimspace() removes accidental leading/trailing whitespace.
  # 2. lower() ensures no uppercase letters (GCP strict requirement).
  # 3. replace(..., " ", "-") converts any internal spaces to hyphens.

  common_tags = {
    project     = replace(lower(trimspace(var.project_name)), " ", "-")
    environment = lower(var.environment) # Already validated in variables.tf, but kept safe
    owner       = replace(lower(trimspace(var.project_owner)), " ", "-")
    managed_by  = "terraform"
    repository  = "gcp-landing-zone"
  }
}
