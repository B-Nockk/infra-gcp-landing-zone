#!/usr/bin/env bash
# ============================== ==============================
# Terraform Init Wrapper
# ============================== ==============================
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export PLATFORM_DIR="${PROJECT_ROOT}/platform_tooling"

# ============================== ==============================
# Configuration & Expected Variables
# ============================== ==============================
ENV_FILE="${PLATFORM_DIR}/config/platform.env"
EXPECTED_VARS=("GCP_PROJECT_ID")

# ============================== ==============================
# Initialization
# ============================== ==============================
source "${PLATFORM_DIR}/scripts/lib.sh"
load_env_vars "$ENV_FILE" "${EXPECTED_VARS[@]}"

# ============================== ==============================
# Argument Parsing
# ============================== ==============================
TF_BIN="${1:-terraform}"
ENV="${2:-dev}"

# Safely discard the first two arguments to isolate any extra Terraform flags
if [[ $# -ge 2 ]]; then
    shift 2
else
    shift $#
fi
EXTRA_TF_ARGS=("$@")

ENV_DIR="${PROJECT_ROOT}/terraform/environments/${ENV}"
BACKEND_CONFIG="${PLATFORM_DIR}/config/backend-${ENV}.hcl"

# ============================== ==============================
# Functions (Unit-contained logic)
# ============================== ==============================

run_local_init() {
    log "INFO" "Environment is 'local'. Initializing with local backend..."
    cd "$ENV_DIR" && "$TF_BIN" init -upgrade "${EXTRA_TF_ARGS[@]}"
}

run_remote_init() {
    if [[ ! -f "$BACKEND_CONFIG" ]]; then
        log "ERROR" "Backend config not found: $BACKEND_CONFIG"
        log "INFO" "Run 'make bootstrap ENV=$ENV' first."
        exit 1
    fi

    log "INFO" "Initializing environment: $ENV with backend config..."
    cd "$ENV_DIR" && "$TF_BIN" init -upgrade -backend-config="$BACKEND_CONFIG" "${EXTRA_TF_ARGS[@]}"
}

# ============================== ==============================
# Main Execution
# ============================== ==============================
require_command "$TF_BIN"
require_command "gcloud"
require_gcloud_auth

if [[ "$ENV" == "local" ]]; then
    run_local_init
else
    run_remote_init
fi

log "SUCCESS" "Terraform initialization complete."
