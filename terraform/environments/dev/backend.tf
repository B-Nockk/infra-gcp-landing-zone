# terraform/environments/dev/backend.tf
# terraform {
#   backend "gcs" {
#     bucket = "REPLACE_ME_VIA_INIT"
#     prefix = "env/dev"

#     # Optional but recommended: Enable state locking using a GCS object lock
#     # (GCS handles this natively when used as a backend)
#   }
# }

# terraform/environments/dev/backend.tf
terraform {
  # The actual bucket and prefix are injected via -backend-config during `make init`.
  # This empty block simply declares the backend type.
  backend "gcs" {}
}
