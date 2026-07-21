# 001. Pre-provisioned GCP Projects as Input Variables

## Status

Accepted

## Context

In our previous Azure implementations, Terraform managed the creation of the Resource Group alongside the resources inside it.
In GCP, the equivalent boundary is the Project. However, enterprise GCP best practices dictate that Projects should be provisioned separately from the workloads they contain. This ensures that billing, folder placement, and Organization Policies are applied before any infrastructure is deployed.

## Decision

The GCP Landing Zone Terraform repository will **not** create the GCP Project.
Instead, the pre-existing `project_id` (and `project_name`) will be passed into the `common` module as input variables. The `resource_computed_names` local will use `var.project_id` as the foundational anchor for all internal resource naming.

## Consequences

- **Pros:** Enforces separation of concerns. The platform team manages project lifecycle; the application/landing zone team manages resources inside it. Prevents accidental project deletion if the landing zone Terraform state is destroyed.
- **Cons:** Requires an external process (manual or separate Org-level Terraform) to create the project before running this code.
- **Naming:** The `project_id` variable acts as the single source of truth for the project boundary, replacing the dynamically generated Azure-style Resource Group name.
