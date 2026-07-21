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

variable "region_short" {
  description = "GCP region abbreviation/token"
  type        = string
}

variable "instance_id" {
  description = "unique alphanumeric index identifier for resource uniqueness (e.g 001)"
  type        = string
}
