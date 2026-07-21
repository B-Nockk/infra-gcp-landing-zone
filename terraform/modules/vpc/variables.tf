# terraform/modules/network/variables.tf

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "common_tags" {
  description = "Platform standard labels (must be lowercase)."
  type        = map(string)
}

# terraform/modules/vpc/variables.tf

variable "resource_computed_names" {
  description = "Enterprise resource naming catalogue from the common module."
  type = object({
    project_id = string
    vpcs = object({
      primary = object({
        name            = string
        firewall_prefix = string
        route_prefix    = string
        subnets = object({
          public_subnet     = string
          private_subnet    = string
          management_subnet = string
        })
      })
    })
  })
}

# ============================== ==============================
# STRICT GCP NETWORK CONFIGURATION
# ============================== ==============================

variable "vpcs" {
  description = "Map of VPC networks and their associated subnets, firewalls, and routes."
  type = map(object({
    routing_mode = string # GLOBAL or REGIONAL (Per VPC!)

    subnets = map(object({
      ip_cidr_range = string
      region        = string
    }))

    firewall_rules = map(object({
      priority      = number
      direction     = string
      action        = string
      source_ranges = list(string)
      target_tags   = list(string)
      rules = list(object({
        protocol = string
        ports    = list(string)
      }))
    }))

    routes = map(object({
      dest_range    = string
      next_hop_type = string
      next_hop      = string
      target_tags   = list(string)
    }))
  }))

  validation {
    # This validates that EVERY VPC in the map has a valid routing mode
    condition = alltrue([
      for k, v in var.vpcs : contains(["GLOBAL", "REGIONAL"], v.routing_mode)
    ])
    error_message = "Every VPC must have a routing_mode of either 'GLOBAL' or 'REGIONAL'."
  }
}
