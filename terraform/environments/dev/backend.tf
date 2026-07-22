# terraform/environments/dev/backend.tf

terraform {
  backend "gcs" {
    bucket = "tfstate-ttl-landing-zone-dev" # The bucket we just created
    prefix = "env/dev"                      # Acts like a "folder" inside the bucket

    # Optional but recommended: Enable state locking using a GCS object lock
    # (GCS handles this natively when used as a backend)
  }
}
