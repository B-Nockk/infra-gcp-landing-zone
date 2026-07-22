variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region where the compute fleet will run."
  type        = string
}

variable "common_tags" {
  description = "Platform standard labels."
  type        = map(string)
}

# Narrowed to just the four workload-scoped names compute actually uses.
variable "resource_computed_names" {
  description = "Enterprise resource naming catalogue (only the workload-scoped names this module needs)."
  type = object({
    project_id = string
    workloads = map(object({
      instance_prefix   = string
      instance_template = string
      instance_group    = string
      health_check      = string
    }))
  })
}

variable "subnet_self_links" {
  description = "Map of subnet keys to their self_links (passed from network module outputs)."
  type        = map(string)
}

variable "service_account_emails" {
  description = "Map of workload keys to their Service Account emails (passed from IAM module)."
  type        = map(string)
}

# Replaces the old standalone `compute` variable. Compute reads the SSOT `workloads`
# map directly and flattens out just the entries that declare a compute fleet
# (see locals.tf) — this is the "flattening happens where it's needed" part.
variable "workloads" {
  description = "Single source of truth per-workload map (from environment var.workloads)."
  type = map(object({
    description = string

    iam = object({
      roles = list(string)
    })

    compute = optional(object({
      machine_type       = string
      fleet_size         = number # We still need this for GCP math
      vpc_key            = string
      subnet_key         = string
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

variable "update_profiles" {
  description = "Library of reusable update policy profiles."
  type = map(object({
    minimal_action          = string
    type                    = string
    max_surge_fixed         = optional(number)
    max_unavailable_fixed   = optional(number)
    max_surge_percent       = optional(number)
    max_unavailable_percent = optional(number)
  }))
}
