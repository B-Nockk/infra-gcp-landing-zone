# Platform Tooling

This directory contains the orchestration layer for the GCP Infrastructure. It is designed to abstract away cloud provider complexities, enforce security best practices, and provide a consistent developer experience.

## Directory Structure

- `config/`: Environment-specific configurations. `platform.env` is the single source of truth for tooling variables. `backend-*.hcl` files are auto-generated.
- `scripts/`:
  - `lib.sh`: Shared library for color-coded logging and strict environment variable loading.
  - `bootstrap-state.sh`: Idempotently creates the GCS state bucket and enables versioning.
  - `terraform-init.sh`: Wrapper that ensures auth is valid before running `terraform init`.
  - `auth-wrapper.sh`: Pluggable authentication entry point.
- `terraform.mk`: Semantic Makefile included by the root `Makefile`.

## Custom Authentication (For Local/collaboration Use)

To use a specific GCP account without altering your global default, create a custom ADC file:

1. Create the secrets directory: `mkdir -p platform_tooling/secrets`
2. Log in with your specific account: `gcloud auth application-default login --account=your-email@gmail.com`
3. Copy the generated credentials: `cp ~/.config/gcloud/application_default_credentials.json platform_tooling/secrets/custom-adc.json`
4. The `auth-wrapper.sh` will automatically detect and source `platform_tooling/scripts/custom-auth.sh`, which should contain:

   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/platform_tooling/secrets/custom-adc.json"
   ```
