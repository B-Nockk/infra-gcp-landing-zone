# versions.tf
terraform {
  required_version = ">= 1.5.7"

  # ============================== ==============================
  # Required providers
  # ============================== ==============================
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Latest stable major version
    }
    # google-beta = {
    #   source  = "hashicorp/google-beta"
    #   version = "~> 5.0" # For beta features (optional)
    # }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
