#!/usr/bin/env bash
# ============================== ==============================
# Platform Tooling Shared Library
# ============================== ==============================
# Source this file in other scripts to use shared logging and config functions.

# ==============================================================================
# Logging Functions
# ==============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m' # No Color

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    local color="$COLOR_NC"
    case "$level" in
        INFO)    color="$COLOR_BLUE" ;;
        SUCCESS) color="$COLOR_GREEN" ;;
        WARN)    color="$COLOR_YELLOW" ;;
        ERROR)   color="$COLOR_RED" ;;
    esac

    # Format: [YYYY-MM-DD HH:MM:SS][LEVEL] - message
    printf "${color}[%s][%s] - %s${COLOR_NC}\n" "$timestamp" "$level" "$message" >&2
}

# ==============================================================================
# Configuration Functions
# ==============================================================================

# Reads specific variables from an env file into the current shell scope
# WITHOUT exporting them to the process environment.
# Usage: load_env_vars "/path/to/file.env" "VAR1" "VAR2"
load_env_vars() {
    local file="$1"
    shift
    local vars_to_load=("$@")

    if [[ ! -f "$file" ]]; then
        log "ERROR" "Configuration file not found: $file"
        exit 1
    fi

    for var in "${vars_to_load[@]}"; do
        local value
        # Extract value, strip surrounding quotes
        value=$(grep -E "^${var}=" "$file" | head -n 1 | cut -d'=' -f2- | sed -e 's/^["'\'']//' -e 's/["'\'']$//')

        if [[ -z "$value" ]]; then
            log "ERROR" "Required variable '${var}' not found or empty in ${file}"
            exit 1
        fi

        # Assign to variable in current scope (not exported)
        declare -g "$var=$value"
    done
    log "INFO" "Configuration loaded from ${file}"
}

# ==============================================================================
# Dependency & Auth Checks
# ==============================================================================
require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "ERROR" "Missing required dependency: $cmd"
        exit 1
    fi
}

require_gcloud_auth() {
    # Check for custom auth script first (pluggable)
    local custom_auth="${PLATFORM_DIR}/scripts/custom-auth.sh"
    if [[ -f "$custom_auth" ]]; then
        log "INFO" "Sourcing custom auth script..."
        source "$custom_auth"
    fi

    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        log "ERROR" "Not authenticated with Google Cloud."
        log "INFO" "Run: gcloud auth login"
        exit 1
    fi
    log "INFO" "GCP authentication verified."
}
