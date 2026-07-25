# ==============================================================================
# 1. Organization Policies (Project-Level Guardrails)
# ==============================================================================
# Note: The 'name' attribute is strictly dictated by the GCP API format:
# projects/{project_id}/policies/{constraint_name}. We cannot use custom naming here.

resource "google_org_policy_policy" "this" {
  for_each = var.org_policies

  # GCP API mandates this exact string format for the policy name
  name   = "projects/${var.project_id}/policies/${each.key}"
  parent = "projects/${var.project_id}"

  spec {
    rules {
      enforce = each.value.enforce ? "TRUE" : "FALSE"
    }
  }
}

# ==============================================================================
# 2. VPC Service Controls (Data Perimeter - Org Level)
# ==============================================================================
# Only created if var.vpc_service_controls is explicitly provided in tfvars.

resource "google_access_context_manager_access_policy" "this" {
  count  = var.vpc_service_controls != null ? 1 : 0
  parent = "organizations/${var.vpc_service_controls.org_id}"
  title  = "landing-zone-perimeter-policy"
}

resource "google_access_context_manager_service_perimeter" "this" {
  count  = var.vpc_service_controls != null ? 1 : 0
  parent = "accessPolicies/${google_access_context_manager_access_policy.this[0].name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.this[0].name}/servicePerimeters/${var.vpc_service_controls.perimeter_name}"
  title  = var.vpc_service_controls.perimeter_name

  status {
    restricted_services = var.vpc_service_controls.restricted_services

    vpc_accessible_services {
      allowed_services   = var.vpc_service_controls.restricted_services
      enable_restriction = true
    }

    resources = var.vpc_service_controls.restricted_resources
  }
}
