# terraform/environments/dev/outputs_registry.tf

# ============================== ==============================
# Cross-Repo Outputs Registry (Approach B)
# ============================== ==============================
# This file defines the explicit contract published to the GCS registry bucket.
# Downstream repos read this JSON, never the raw Terraform state.

locals {
  # The explicit contract: ONLY what downstream repos need is published here.
  published_outputs = {
    vpc_self_links                  = module.network.vpc_ids
    subnet_self_links               = module.network.subnet_self_links
    workload_service_account_emails = module.iam.service_account_emails
    mig_instance_groups             = module.compute.instance_group_self_links
  }
}

resource "google_storage_bucket_object" "outputs_registry" {
  # Name is pulled directly from the common module's computed names
  name    = module.common.resource_computed_names.state_outputs_registry_path
  bucket  = var.state_bucket_name
  content = jsonencode(local.published_outputs)

  # Ensure this is created AFTER the resources it references
  depends_on = [
    module.network,
    module.iam,
    module.compute
  ]
}
