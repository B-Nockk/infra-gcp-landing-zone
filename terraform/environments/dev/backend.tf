# terraform/environments/dev/backend.tf
terraform {
  backend "gcs" {
    bucket = "REPLACE_ME_VIA_INIT"
    prefix = "env/dev"

    # Optional but recommended: Enable state locking using a GCS object lock
    # (GCS handles this natively when used as a backend)
  }
}
