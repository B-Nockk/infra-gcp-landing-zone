# terraform/modules/iam/main.tf

# 1. Create the Service Accounts
resource "google_service_account" "this" {
  for_each = var.workloads

  # Was var.workload_names[each.key] — that variable was never declared anywhere.
  # Now reads straight from common's naming catalogue.
  account_id   = var.resource_computed_names.workloads[each.key].service_account
  display_name = each.value.description
  project      = var.project_id
}

# 2. Assign the Roles to the Service Accounts
resource "google_project_iam_member" "this" {
  for_each = merge([
    for sa_key, sa_config in var.workloads : {
      for role in sa_config.iam.roles :
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
