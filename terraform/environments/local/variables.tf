# terraform/modules/common/variables.tf

# ============================== ==============================
# COMMON SHARED CONFIGURATION
# ============================== ==============================

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

variable "project_id" {
  description = "project id"
  type        = string
}

# ============================== ==============================
# SERVER & ENVIRONMENT CONFIGURATION
# ============================== ==============================
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
    condition = alltrue([
      for k, v in var.vpcs : contains(["GLOBAL", "REGIONAL"], v.routing_mode)
    ])
    error_message = "Every VPC must have a routing_mode of either 'GLOBAL' or 'REGIONAL'."
  }
}

# ============================== ==============================
# WORKLOADS — single source of truth: identity + IAM + (optional) compute
# Replaces the old separate `workloads` + `compute` variables.
# ============================== ==============================

variable "workloads" {
  description = "Map of workloads: description, IAM roles, and an optional compute fleet definition."
  type = map(object({
    description = string

    iam = object({
      roles = list(string)
    })

    # optional() so a future identity-only workload (no VM) doesn't need a compute block.
    compute = optional(object({
      machine_type       = string
      vpc_key            = string # logical key into var.vpcs (e.g. "primary")
      subnet_key         = string # logical key into that VPC's subnets (e.g. "private_subnet")
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
  }))
}
