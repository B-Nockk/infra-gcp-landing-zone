# terraform/modules/iam/variables.tf

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "resource_computed_names" {
  description = "Naming catalogue."
  type = object({
    project_id = string
    iam_prefix = string # We will add this to common module
  })
}

variable "workloads" {
  description = "Map of workload identities (Service Accounts) and their required GCP roles."
  type = map(object({
    display_name = string
    description  = string
    roles        = list(string) # e.g., ["roles/logging.logWriter", "roles/storage.objectViewer"]
  }))
}
