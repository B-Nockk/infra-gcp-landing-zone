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
# Arguments
# ============================== ==============================
TF_BIN="${1:-terraform}"
ENV="${2:-dev}"
ENV_DIR="${PROJECT_ROOT}/terraform/environments/${ENV}"
BACKEND_CONFIG="${PLATFORM_DIR}/config/backend-${ENV}.hcl"

# ============================== ==============================
# Main Logic
# ============================== ==============================
require_command "$TF_BIN"
require_command "gcloud"
require_gcloud_auth

if [[ "$ENV" == "local" ]]; then
    log "INFO" "Environment is 'local'. Initializing with local backend..."
    cd "$ENV_DIR" && "$TF_BIN" init -upgrade
else
    if [[ ! -f "$BACKEND_CONFIG" ]]; then
        log "ERROR" "Backend config not found: $BACKEND_CONFIG"
        log "INFO" "Run 'make bootstrap ENV=$ENV' first."
        exit 1
    fi

    log "INFO" "Initializing environment: $ENV"
    cd "$ENV_DIR" && "$TF_BIN" init -upgrade -backend-config="$BACKEND_CONFIG"
fi

log "SUCCESS" "Terraform initialization complete."
