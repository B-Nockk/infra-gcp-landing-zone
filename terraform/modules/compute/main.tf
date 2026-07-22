# terraform/modules/compute/main.tf

# ============================== ==============================
# 1. Health Checks (Dynamic per instance)
# ============================== ==============================
resource "google_compute_health_check" "this" {
  for_each = var.compute

  # Name: hc-lndzn-dev-euw1-01-app
  name    = "${var.resource_computed_names.compute.health_check_prefix}-${each.key}"
  project = var.project_id

  http_health_check {
    port         = each.value.health_check.port
    request_path = each.value.health_check.request_path
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# ============================== ==============================
# 2. Instance Templates (The Blueprints)
# ============================== ==============================
resource "google_compute_instance_template" "this" {
  for_each = var.compute

  # Name Prefix: tmpl-lndzn-dev-euw1-01-app- (Terraform appends a random hash)
  name_prefix  = "${var.resource_computed_names.compute.instance_template_prefix}-${each.key}-"
  project      = var.project_id
  machine_type = each.value.machine_type
  region       = var.region

  disk {
    source_image = each.value.boot_disk.image
    disk_size_gb = each.value.boot_disk.size
    disk_type    = each.value.boot_disk.type
    boot         = true
  }

  network_interface {
    # Dynamically link to the correct subnet using the key from tfvars
    subnetwork = var.subnet_self_links[each.value.subnet_key]

    dynamic "access_config" {
      for_each = each.value.assign_external_ip ? [1] : []
      content {}
    }
  }

  tags   = each.value.network_tags
  labels = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# ============================== ==============================
# 3. Managed Instance Groups (The Fleets)
# ============================== ==============================
resource "google_compute_region_instance_group_manager" "this" {
  for_each = var.compute

  # Name: mig-lndzn-dev-euw1-01-app
  name    = "${var.resource_computed_names.compute.instance_group_prefix}-${each.key}"
  project = var.project_id
  region  = var.region

  version {
    instance_template = google_compute_instance_template.this[each.key].id
  }

  target_size        = 2
  base_instance_name = "vm-${each.key}"

  # Link the auto-healing to the specific health check we created for this instance!
  auto_healing_policies {
    health_check      = google_compute_health_check.this[each.key].id
    initial_delay_sec = 300 # Give the app 5 mins to boot before checking health
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
  }
}
