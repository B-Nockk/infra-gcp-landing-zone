# terraform/modules/compute/locals.tf
locals {
  # Only workloads that declared a compute block get a VM fleet here. This is the
  # module's own flattening of the shared SSOT map — common and the environment
  # never need to know compute exists.
  compute_workloads = {
    for key, workload in var.workloads : key => workload.compute
    if workload.compute != null
  }
}
