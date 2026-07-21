# 001. GCP Project ID Naming Constraints

## Status

Accepted

## Context

In our previous Azure implementations, Resource Groups could be up to 90 characters.
In GCP, the equivalent boundary is the Project ID, which is strictly limited to 6-30 characters.
Furthermore, GCP Project IDs do not allow uppercase letters, meaning we cannot use camelCase to save space.

## Decision

We will implement a dual-naming strategy in the `common` module:

1. `project_id`: Strictly truncated to 30 characters, lowercase, hyphen-separated. Used for the actual GCP Project creation.
2. `resource_group_display_name`: Uses the full standard naming convention (up to 63 chars) for display purposes and internal resource tagging.

We will also enforce shorter region tokens (e.g., `euw1` instead of `europe-west1`) in the `regions.tf` mapping to preserve character space.

## Consequences

- Engineers must be aware that the GCP Console Project ID will look slightly abbreviated compared to the resources inside it.
- We avoid Terraform apply failures caused by GCP API 400 Bad Request errors on Project creation.
