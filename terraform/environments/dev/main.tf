# terraform/environments/dev/main.tf

# 1. Fetch the pre-provisioned project details (Optional but good practice)
# data "google_project" "this" {
#   project_id = var.project_id
# }

# 2. Call the common module to get names and tags
module "common" {
  source = "../../modules/common"

  project_id    = var.project_id
  project_name  = var.project_name
  project_token = var.project_token
  project_owner = var.project_owner
  environment   = var.environment
  region_short  = var.region_short
  instance_id   = var.instance_id
}

# 3. Call the network module
module "vpc" {
  source = "../../modules/vpc"

  project_id = var.project_id
  # region                  = var.gcp_region  <-- DELETE THIS LINE

  common_tags             = module.common.common_tags
  resource_computed_names = module.common.resource_computed_names

  # CHANGE THIS: network is now vpcs
  vpcs = var.vpcs
}
