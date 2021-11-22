#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

# install missing gems
bundle check || bundle install --jobs 20 --retry 5

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid


#!/usr/bin/env bash
set -eo pipefail

# Validate Tor config

TOR_HOSTNAME=$(cat "${APP_PATH}/hidden_service/hostname")

# Print some useful info
echo ""
echo "[TOR] ==================================================================="
echo "[TOR] Starting onion service at ${TOR_HOSTNAME}"
echo "[TOR] You may dangerously print your hs_ed25519_secret_key by running this command:"
echo "[TOR] heroku ps:exec --dyno=${DYNO} 'cat \"${APP_PATH}/hidden_service/hs_ed25519_secret_key\"'"
echo "[TOR] ==================================================================="
echo ""

# Start Tor
"tor" -f "${APP_PATH}/config/torrc-dev" & bundle exec ${@}
# run passed commands