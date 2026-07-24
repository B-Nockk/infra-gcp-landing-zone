# terraform/modules/common/resource_computed_names.tf

locals {
  resource_computed_names = {
    # Conceptually the "Resource Group", but named for GCP reality
    project_id = var.project_id

    # Dynamic across ANY number of VPCs/subnets — no more hardcoded "primary".
    # Both the VPC key and the subnet key are folded into every name, so two
    # VPCs each with a "public_subnet" can never collide.
    vpcs = {
      for vpc_key, subnet_keys in var.vpc_subnet_keys : vpc_key => {
        name = join(local.sep.hyphen, [
          local.resource_type_token.vpc, vpc_key, local.resource_identifier
        ])

        subnets = {
          for subnet_key in subnet_keys : subnet_key => join(local.sep.hyphen, [
            local.resource_type_token.subnet, vpc_key, subnet_key, local.resource_identifier
          ])
        }

        # Prefixes for dynamic resources (firewalls/routes) — the vpc module
        # appends its own rule/route key to these. This is the only place
        # that prefix is ever built.
        firewall_prefix = join(local.sep.hyphen, [
          local.resource_type_token.firewall_rule, vpc_key, local.resource_identifier
        ])

        route_prefix = join(local.sep.hyphen, [
          local.resource_type_token.route, vpc_key, local.resource_identifier
        ])
      }
    }

    # Every name a workload could need — service account, instance template,
    # instance group, health check, and the VM base-name prefix. One place,
    # so iam/compute never invent a naming fragment of their own again.
    workloads = {
      for key in var.workload_keys : key => {
        service_account   = join(local.sep.hyphen, [local.resource_type_token.service_account, key, local.resource_identifier])
        instance_prefix   = join(local.sep.hyphen, [local.resource_type_token.compute_instance, key, local.resource_identifier])
        instance_template = join(local.sep.hyphen, [local.resource_type_token.instance_template, key, local.resource_identifier])
        instance_group    = join(local.sep.hyphen, [local.resource_type_token.managed_instance_group, key, local.resource_identifier])
        health_check      = join(local.sep.hyphen, [local.resource_type_token.health_check, key, local.resource_identifier])
      }
    }

    # Cross-Repo Registry Path
    # Generates: "registry/dev/v1/outputs.json"
    state_outputs_registry_path = join(local.sep.slash, [
      var.state_registry_prefix,
      var.environment,
      "v1",
      "outputs.json"
    ])
  }
}
