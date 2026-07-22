# terraform/modules/compute/main.tf

# ============================== ==============================
# 1. Health Checks (Dynamic per instance)
# ============================== ==============================
resource "google_compute_health_check" "this" {
  for_each = local.compute_workloads

  name    = var.resource_computed_names.workloads[each.key].health_check
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
  for_each = local.compute_workloads

  name_prefix  = "${var.resource_computed_names.workloads[each.key].instance_template}-"
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
    # Resolves to "primary-private_subnet" etc. If it doesn't exist, Terraform fails
    # fast — no silent fallbacks.
    subnetwork = var.subnet_self_links["${each.value.vpc_key}-${each.value.subnet_key}"]

    dynamic "access_config" {
      for_each = each.value.assign_external_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.service_account_emails[each.key]
    scopes = ["cloud-platform"]
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
  for_each = local.compute_workloads

  name    = var.resource_computed_names.workloads[each.key].instance_group
  project = var.project_id
  region  = var.region

  version {
    instance_template = google_compute_instance_template.this[each.key].id
  }

  target_size = 2
  # Was hardcoded "vm-${each.key}" — now common's naming catalogue owns this too.
  base_instance_name = var.resource_computed_names.workloads[each.key].instance_prefix

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
