# Compute Update Profiles

## Overview

Update Profiles are reusable, data-driven configurations that control how
Managed Instance Groups (MIGs) perform rolling updates when a new Instance
Template is deployed. They decouple the update strategy from the workload
definition, allowing platform engineers to define a library of strategies
once and reference them by name.

## How It Works

1. Define your profiles in `terraform.tfvars` under the `update_profiles` key.
2. Reference a profile by name in each workload's `compute.update_profile` field.
3. The compute module dynamically applies the correct GCP API fields based on
   which attributes are present in the profile.

## The Toggle Mechanism

GCP's API enforces a strict either/or rule for update policies:

- **Fixed values** (`max_surge_fixed`, `max_unavailable_fixed`): Required for
  fleets with fewer than 10 instances. The surge value MUST be greater than or
  equal to the number of zones in the region (3 for `europe-west1`).
- **Percent values** (`max_surge_percent`, `max_unavailable_percent`): Only
  allowed for fleets with 10 or more instances.

You do NOT need to specify both. Simply include the fields that match your
fleet size, and omit the others. The platform automatically sends `null` for
omitted fields, which GCP silently ignores.

## Profile Examples

### Small Fleet (Fixed Strategy)

```hcl
standard = {
  minimal_action        = "REPLACE"
  type                  = "PROACTIVE"
  max_surge_fixed       = 3   # Must be >= 3 (zone count)
  max_unavailable_fixed = 1
}
```

### Large Fleet (Percent Strategy)

```hcl
canary = {
  minimal_action          = "RESTART"
  type                    = "PROACTIVE"
  max_surge_percent       = 10
  max_unavailable_percent = 5
}
```

### Zero-Downtime Production

```hcl
prod_rolling = {
  minimal_action          = "REPLACE"
  type                    = "PROACTIVE"
  max_surge_percent       = 5
  max_unavailable_percent = 0  # Strictly zero downtime
}
```

## GCP Constraints to Remember

| Constraint              | Rule                                                                   |
| ----------------------- | ---------------------------------------------------------------------- |
| Regional MIG zone count | `europe-west1` spans 3 zones (b, c, d)                                 |
| `fleet_size` < 10       | Must use `fixed` values                                                |
| `fleet_size` >= 10      | Can use `percent` values                                               |
| `max_surge_fixed`       | Must be >= number of zones (3)                                         |
| `minimal_action`        | `REPLACE`, `RESTART`, or `REFRESH`                                     |
| `type`                  | `PROACTIVE` (immediate) or `OPPORTUNISTIC` (wait for natural restarts) |

## Adding a New Profile

1. Add a new key to the `update_profiles` map in `terraform.tfvars`.
2. Define either `fixed` or `percent` fields (not both).
3. Reference it in your workload: `update_profile = "your-new-profile"`.

**No module code changes required.**
