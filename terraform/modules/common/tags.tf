# terraform/modules/common/tags.tf
locals {
  common_tags = {
    project     = lower(var.project_name)
    environment = lower(var.environment)
    owner       = lower(var.project_owner)
    managed_by  = "terraform"
    repository  = "gcp-landing-zone"
  }
}
