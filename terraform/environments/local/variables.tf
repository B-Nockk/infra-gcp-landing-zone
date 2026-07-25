# terraform/environments/local/variables.tf

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
      fleet_size         = number # We still need this for GCP math
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

      # Reference to update_profiles map key
      update_profile = optional(string, "standard")
    }))
  }))
}

# ============================== ==============================
# COMPUTE PROFILES (Reusable update strategies)
# ============================== ==============================

variable "update_profiles" {
  description = "Library of reusable update policy profiles. Supports both 'fixed' (for small fleets) and 'percent' (for large fleets) strategies."
  type = map(object({
    minimal_action = string
    type           = string # PROACTIVE or OPPORTUNISTIC

    # Fixed strategy (Required for fleets < 10 instances)
    max_surge_fixed       = optional(number)
    max_unavailable_fixed = optional(number)

    # Percent strategy (Required for fleets >= 10 instances)
    max_surge_percent       = optional(number)
    max_unavailable_percent = optional(number)
  }))

  # default = {
  #   # Strategy for small/dev fleets (Uses Fixed)
  #   standard = {
  #     minimal_action        = "REPLACE"
  #     type                  = "PROACTIVE"
  #     max_surge_fixed       = 3 # Must be >= number of zones (3)
  #     max_unavailable_fixed = 0 # Zero downtime
  #   }

  #   # Strategy for large/prod fleets (Uses Percent)
  #   canary = {
  #     minimal_action          = "REPLACE"
  #     type                    = "PROACTIVE"
  #     max_surge_percent       = 20
  #     max_unavailable_percent = 0 # Zero downtime
  #   }
  # }
}


# ============================== ==============================
# REMOTE STATE REGISTRY
# ============================== ==============================

variable "state_registry_prefix" {
  description = "The prefix inside the bucket used for the outputs registry."
  type        = string
}

variable "override_computed_state_bucket_name" {
  description = "Optional override for the state bucket name. Leave empty to use the auto-computed name."
  type        = string
  default     = ""
}

variable "state_bucket_prefix" {
  description = "The prefix used to compute the state bucket name (e.g., 'tfstate')."
  type        = string
}

variable "org_policies" {
  description = "Data-driven map of GCP Organization Policies to enforce."
  type = map(object({
    enforce = bool
  }))
  default = {}
}

variable "vpc_service_controls" {
  description = "Optional VPC Service Controls configuration."
  type = object({
    org_id               = string
    perimeter_name       = string
    restricted_services  = list(string)
    restricted_resources = list(string)
  })
  default = null
}
