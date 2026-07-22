# terraform/modules/iam/variables.tf

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

# Narrowed to just what iam needs — common produces more, Terraform drops the rest.
variable "resource_computed_names" {
  description = "Naming catalogue (only the workload service-account names this module needs)."
  type = object({
    project_id = string
    workloads = map(object({
      service_account = string
    }))
  })
}

variable "workloads" {
  description = "Single source of truth per-workload map (description, IAM roles, optional compute)."
  type = map(object({
    description = string

    iam = object({
      roles = list(string)
    })

    compute = optional(object({
      machine_type       = string
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
    }))
  }))
}
