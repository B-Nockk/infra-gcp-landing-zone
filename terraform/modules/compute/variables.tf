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

# The actual compute configuration
variable "compute" {
  description = "Map of compute fleets (Instance Templates + MIGs)."
  type = map(object({
    machine_type = string

    boot_disk = object({
      image = string
      size  = number
      type  = string
    })

    # The logical name of the subnet (e.g., "private_subnet")
    subnet_key = string

    # Network tags for firewall targeting
    network_tags = list(string)

    # External IP toggle
    assign_external_ip = bool

    # Health Check Configuration (Data-driven!)
    health_check = object({
      port         = number
      request_path = string # e.g., "/healthz"
      protocol     = string # "HTTP" or "HTTPS" or "TCP"
    })
  }))
}
