#!/bin/sh
set -e

TOR_HOSTNAME=$(cat "${APP_PATH}/hidden_service/hostname")

# Print some useful info
echo ""
echo "[TOR] ==================================================================="
echo "[TOR] Starting onion service at ${TOR_HOSTNAME}"
echo "[TOR] ==================================================================="
echo ""

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
