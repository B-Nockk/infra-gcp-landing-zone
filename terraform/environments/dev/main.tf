# terraform/environments/dev/main.tf

# ============================== ==============================
# 1. Provider Configuration
# ============================== ==============================
provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

# ============================== ==============================
# 2. Common Module (The Single Source of Truth for Naming/Tags)
# ============================== ==============================
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

# ============================== ==============================
# 3. Network Module (VPCs, Subnets, Firewalls, Routes)
# ============================== ==============================
module "network" {
  source = "../../modules/vpc" # (or vpc, depending on your folder name)

  project_id              = var.project_id
  common_tags             = module.common.common_tags
  resource_computed_names = module.common.resource_computed_names

  vpcs = var.vpcs
}

# ============================== ==============================
# 4. Compute Module (Templates, MIGs, Health Checks)
# ============================== ==============================
module "iam" {
  source = "../../modules/iam"

  project_id              = var.project_id
  resource_computed_names = module.common.resource_computed_names

  workloads = var.workloads
}

# ============================== ==============================
# 4. Compute Module (Templates, MIGs, Health Checks)
# ============================== ==============================
module "compute" {
  source = "../../modules/compute"

  project_id              = var.project_id
  region                  = var.gcp_region
  common_tags             = module.common.common_tags
  resource_computed_names = module.common.resource_computed_names
  subnet_self_links       = module.network.subnet_self_links  # WIRE-UP the network module's outputs directly into compute
  service_account_emails  = module.iam.service_account_emails # THE WIRE-UP
  compute                 = var.compute
  # network_self_links    = module.network.subnet_self_links
}
