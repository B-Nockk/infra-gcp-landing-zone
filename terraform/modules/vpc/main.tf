# terraform/modules/vpc/main.tf

# ============================== ==============================
# 1. VPC Network (Parent)
# ============================== ==============================
resource "google_compute_network" "this" {
  for_each = var.vpcs

  name                    = var.resource_computed_names.vpcs[each.key].name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = each.value.routing_mode
}

# ============================== ==============================
# 2. Subnets (Child)
# ============================== ==============================
resource "google_compute_subnetwork" "this" {
  for_each = local.flattened_subnets # Use the flattened local!

  # Look up the name using the specific vpc_key and subnet_key from the flattened value
  name    = var.resource_computed_names.vpcs[each.value.vpc_key].subnets[each.value.subnet_key]
  project = var.project_id
  region  = each.value.region

  # Link back to the specific parent VPC instance!
  network = google_compute_network.this[each.value.vpc_key].id

  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ============================== ==============================
# 3. Routes (Child)
# ============================== ==============================
resource "google_compute_route" "this" {
  for_each = local.flattened_routes # Use the flattened local!

  # Combine the prefix from common with the specific route_key
  name    = "${var.resource_computed_names.vpcs[each.value.vpc_key].route_prefix}-${each.value.route_key}"
  project = var.project_id

  # Link back to the specific parent VPC instance!
  network = google_compute_network.this[each.value.vpc_key].name

  dest_range = each.value.dest_range

  next_hop_gateway  = each.value.next_hop_type == "internet_gateway" ? "default-internet-gateway" : null
  next_hop_instance = each.value.next_hop_type == "instance" ? each.value.next_hop : null

  tags = each.value.target_tags
}
