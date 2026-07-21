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

    vpc_networks = {
      primary = join(local.sep.hyphen, [
        local.resource_type_token.vpc_network,
        local.resource_identifier
      ])
    }

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
  }
}
