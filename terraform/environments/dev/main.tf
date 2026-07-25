# terraform/environments/dev/main.tf

# ============================== ==============================
# Provider Configuration
# ============================== ==============================
provider "google" {
  project               = var.project_id
  region                = var.gcp_region
  billing_project       = var.project_id
  user_project_override = true
}

# ============================== ==============================
# Common Module (The Single Source of Truth for Naming/Tags)
# ============================== ==============================
module "common" {
  source = "../../modules/common"

  project_id                          = var.project_id
  project_name                        = var.project_name
  project_token                       = var.project_token
  project_owner                       = var.project_owner
  environment                         = var.environment
  region_short                        = var.region_short
  instance_id                         = var.instance_id
  state_registry_prefix               = var.state_registry_prefix # Pass from tfvars
  state_bucket_prefix                 = var.state_bucket_prefix
  override_computed_state_bucket_name = var.override_computed_state_bucket_name

  # Common only ever needs KEYS to generate names for — never the full schema.
  # This is the one and only place vpcs/workloads get "flattened" for common's benefit.
  vpc_subnet_keys = { for vpc_key, vpc_cfg in var.vpcs : vpc_key => keys(vpc_cfg.subnets) }
  workload_keys   = keys(var.workloads)
}

# ============================== ==============================
# Enable all required
# ============================== ==============================
module "project_services" {
  source = "../../modules/project-services"

  project_id    = var.project_id
  required_apis = module.common.required_apis
}

# ============================== ==============================
# Network Module (VPCs, Subnets, Firewalls, Routes)
# ============================== ==============================
module "network" {
  source = "../../modules/vpc"

  project_id              = var.project_id
  common_tags             = module.common.common_tags
  resource_computed_names = module.common.resource_computed_names

  vpcs = var.vpcs
}

# ============================== ==============================
# IAM Module (Service Accounts + Role Bindings)
# ============================== ==============================
module "iam" {
  source = "../../modules/iam"

  project_id              = var.project_id
  resource_computed_names = module.common.resource_computed_names

  workloads  = var.workloads
  depends_on = [module.project_services]
}

# ============================== ==============================
# Compute Module (Templates, MIGs, Health Checks)
# ============================== ==============================
module "compute" {
  source = "../../modules/compute"

  project_id              = var.project_id
  region                  = var.gcp_region
  common_tags             = module.common.common_tags
  resource_computed_names = module.common.resource_computed_names
  subnet_self_links       = module.network.subnet_self_links  # WIRE-UP the network module's outputs directly
  service_account_emails  = module.iam.service_account_emails # WIRE-UP the iam module's outputs directly
  update_profiles         = var.update_profiles               # Pass the profiles library to the compute module
  workloads               = var.workloads
  depends_on              = [module.project_services]
}

# ============================== ==============================
# Governance Module (Org Policies & Guardrails)
# ============================== ==============================
module "governance" {
  source = "../../modules/governance"

  project_id           = var.project_id
  org_policies         = var.org_policies
  vpc_service_controls = var.vpc_service_controls
  depends_on           = [module.project_services]
}
