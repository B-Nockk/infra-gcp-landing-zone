# terraform/modules/common/variables.tf
variable "project_name" {
  description = "platform project name"
  type        = string
}
variable "project_token" {
  description = "platform project short-form token"
  type        = string
}

variable "project_owner" {
  description = "platform owner"
  type        = string
}

# variable "project_owner_email" {
#   description = "platform owner email"
#   type        = string
# }

variable "project_id" {
  description = "project id"
  type        = string
}

variable "environment" {
  description = "deployment environment"

  validation {
    error_message = "Environment must be local, dev, staging or prod."
    condition = contains(
      ["local", "dev", "staging", "prod"],
      var.environment
    )
  }
}

variable "gcp_region" {
  description = "full GCP region"
  type        = string
}
variable "region_short" {
  description = "GCP region abbreviation/token"
  type        = string
}

variable "instance_id" {
  description = "unique alphanumeric index identifier for resource uniqueness (e.g 001)"
  type        = string
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

# ============================== ==============================
# GCP COMPUTE CONFIGURATION
# ============================== ==============================

variable "compute" {
  description = "Map of compute fleets and their configurations."
  type = map(object({
    machine_type       = string
    vpc_key            = string # NEW: The logical name of the VPC (e.g., "primary")
    subnet_key         = string # The logical name of the subnet (e.g., "private_subnet")
    network_tags       = list(string)
    assign_external_ip = bool

    boot_disk = object({
      image = string
      size  = number
      type  = string
    })

    health_check = object({
      port         = number
      request_path = string
      protocol     = string
    })
  }))
}
