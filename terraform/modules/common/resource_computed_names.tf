# terraform/modules/common/resource_computed_names.tf

locals {
  platform = {
    terraform  = true
    cloud      = "Google-Cloud"
    managed_by = "Benson Ochuko"
  }

  resource_computed_names = {
    # Conceptually the "Resource Group", but named for GCP reality
    project_id = var.project_id

    # Nested under the VPC key ('primary') to match the var.vpcs map structure
    vpcs = {
      primary = {
        name = join(local.sep.hyphen, [
          local.resource_type_token.vpc,
          local.resource_identifier
        ])

        subnets = {
          public_subnet = join(local.sep.hyphen, [
            local.resource_type_token.subnet,
            "public",
            local.resource_identifier
          ])

          private_subnet = join(local.sep.hyphen, [
            local.resource_type_token.subnet,
            "private",
            local.resource_identifier
          ])

          management_subnet = join(local.sep.hyphen, [
            local.resource_type_token.subnet,
            "mgt",
            local.resource_identifier
          ])
        }

        # Prefixes for dynamic resources (Firewalls/Routes)
        # The network module will append the specific rule name to these
        firewall_prefix = join(local.sep.hyphen, [
          local.resource_type_token.firewall_rule,
          local.resource_identifier
        ])

        route_prefix = join(local.sep.hyphen, [
          local.resource_type_token.route,
          local.resource_identifier
        ])

      }
    }

    # COMPUTE NAMES (Root level, providing PREFIXES only)
    compute = {
      instance_template_prefix = join(local.sep.hyphen, [
        local.resource_type_token.instance_template, local.resource_identifier
      ])

      instance_group_prefix = join(local.sep.hyphen, [
        local.resource_type_token.managed_instance_group, local.resource_identifier
      ])

      health_check_prefix = join(local.sep.hyphen, [
        local.resource_type_token.health_check, local.resource_identifier
      ])
    }

  }
}
