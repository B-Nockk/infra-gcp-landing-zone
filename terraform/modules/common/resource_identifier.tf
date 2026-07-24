# terraform/modules/common/resource_identifier.tf

locals {
  sep = {
    hyphen     = "-"
    underscore = "_"
    dot        = "."
    slash      = "/"
  }

  # Standard identifier for most resources (63-char limit)
  # e.g., lndzn-dev-euw1-01
  resource_identifier = join("-", [
    var.project_token,
    var.environment,
    var.region_short,
    var.instance_id
  ])

  # # Short identifier for constrained resources: Project ID, Service Account ID (30-char limit)
  # # e.g., lndzn-dev-euw1
  # short_identifier = join("-", [
  #   var.project_token,
  #   var.environment,
  #   var.region_short
  # ])

  # Safety: hard-truncate to 30 chars and strip trailing hyphens
  # Use this ONLY where the API demands <=30 chars
  # safe_short_id = trimsuffix(substr(local.short_identifier, 0, 30), "-")
}
