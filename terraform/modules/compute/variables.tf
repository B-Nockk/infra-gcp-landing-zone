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

variable "resource_computed_names" {
  description = "Enterprise resource naming catalogue."
  type = object({
    project_id = string
    compute = object({
      instance_template_prefix = string
      instance_group_prefix    = string
      health_check_prefix      = string
    })
  })
}

# variable "network_self_links" {
#   description = "Map of VPC names to their self_links (passed from network module outputs)."
#   type        = map(string)
# }

variable "subnet_self_links" {
  description = "Map of subnet keys to their self_links (passed from network module outputs)."
  type        = map(string)
}

variable "compute" {
  description = "Map of compute fleets and their configurations."
  type = map(object({
    machine_type       = string
    vpc_key            = string # The logical name of the VPC (e.g., "primary")
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
      request_path = string # e.g., "/healthz"
      protocol     = string # "HTTP" or "HTTPS" or "TCP"
    })
  }))
}
