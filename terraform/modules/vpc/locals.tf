# terraform/modules/network/locals.tf

locals {
  # 1. Flatten Subnets
  flattened_subnets = merge([
    for vpc_key, vpc_config in var.vpcs : {
      for subnet_key, subnet_config in vpc_config.subnets :
      "${vpc_key}-${subnet_key}" => {
        vpc_key       = vpc_key
        subnet_key    = subnet_key
        ip_cidr_range = subnet_config.ip_cidr_range
        region        = subnet_config.region
      }
    }
  ]...)

  # 2. Flatten Routes
  flattened_routes = merge([
    for vpc_key, vpc_config in var.vpcs : {
      for route_key, route_config in vpc_config.routes :
      "${vpc_key}-${route_key}" => {
        vpc_key       = vpc_key
        route_key     = route_key
        dest_range    = route_config.dest_range
        next_hop_type = route_config.next_hop_type
        next_hop      = route_config.next_hop
        target_tags   = route_config.target_tags
      }
    }
  ]...)

  # 3. Flatten Firewalls — this local already existed but was unused; the firewall
  # resource used to re-derive the same thing inline. Now it's actually used below.
  flattened_firewalls = merge([
    for vpc_key, vpc_config in var.vpcs : {
      for fw_key, fw_config in vpc_config.firewall_rules :
      "${vpc_key}-${fw_key}" => {
        vpc_key       = vpc_key
        fw_key        = fw_key
        priority      = fw_config.priority
        direction     = fw_config.direction
        action        = fw_config.action
        source_ranges = fw_config.source_ranges
        target_tags   = fw_config.target_tags
        rules         = fw_config.rules
      }
    }
  ]...)
}
