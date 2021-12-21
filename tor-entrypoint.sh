#!/bin/sh
set -e

# ensure hidden service folder has correct perms for tor
chmod 0700 /var/app/hidden_service/

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"


# Validate Tor config

TOR_HOSTNAME=$(cat "${APP_PATH}/hidden_service/hostname")

# Print some useful info
echo ""
echo "[TOR] ==================================================================="
echo "[TOR] Starting onion service at ${TOR_HOSTNAME}"
echo "[TOR] ==================================================================="
echo ""
