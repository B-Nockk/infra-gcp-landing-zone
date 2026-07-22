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

# ============================== ==============================
# NAMING INPUTS — keys only, never the full schema.
# This is what keeps common "dumb": it knows a VPC/subnet/workload
# exists and needs a name, never what it's for.
# ============================== ==============================

variable "vpc_subnet_keys" {
  description = "Map of VPC key to its list of subnet keys, derived from var.vpcs in the environment. Used to generate a name for every VPC/subnet without common needing the network schema."
  type        = map(list(string))
  default     = {}
}

variable "workload_keys" {
  description = "List of workload keys, derived from var.workloads in the environment. Used to generate per-workload resource names without common needing the workload schema."
  type        = list(string)
  default     = []
}
