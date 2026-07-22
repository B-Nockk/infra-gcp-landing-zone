#!/usr/bin/env bash
set -euo pipefail

CUSTOM_AUTH_SCRIPT="platform_tooling/scripts/custom-auth.sh"

if [ -f "$CUSTOM_AUTH_SCRIPT" ]; then
    echo "🔐 Custom auth script detected. Sourcing credentials..."
    # Source the custom script. It should export GOOGLE_APPLICATION_CREDENTIALS
    # or GOOGLE_OAUTH_ACCESS_TOKEN for the current shell session.
    source "$CUSTOM_AUTH_SCRIPT"
else
    echo "ℹ️  No custom auth script found. Relying on default gcloud ADC."
    # Optional: Uncomment the next line if you want to force a login prompt
    # when no custom auth is present.
    # gcloud auth application-default login --quiet
fi
