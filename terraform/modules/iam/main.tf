# terraform/modules/iam/main.tf

# 1. Create the Service Accounts
resource "google_service_account" "this" {
  for_each = var.workloads

  account_id   = "${var.resource_computed_names.iam_prefix}-${each.key}"
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

# 2. Assign the Roles to the Service Accounts
# We use a nested loop to flatten the map of roles for each SA
resource "google_project_iam_member" "this" {
  for_each = merge([
    for sa_key, sa_config in var.workloads : {
      for role in sa_config.roles :
      "${sa_key}-${role}" => {
        sa_key = sa_key
        role   = role
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.this[each.value.sa_key].email}"
}
