# terraform/modules/common/tags.tf
locals {
  common_tags = {
    Project     = upper(var.project_name)
    Environment = upper(var.environment)
    Owner       = upper(var.project_owner)
    Managed_by  = "Terraform"
    repository  = "google-cloud-platform"
  }
}
