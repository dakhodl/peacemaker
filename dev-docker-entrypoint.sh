#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

# TODO: move this out of start, is just for easy onboarding.
# needed quick solution to manifest.json missing
# bundle exec rake webpacker:install


#!/usr/bin/env bash
set -eo pipefail

# Validate Tor config

TOR_HOSTNAME=$(cat "${APP_PATH}/hidden_service/hostname")

# Print some useful info
echo ""
echo "[TOR] ==================================================================="
echo "[TOR] Starting onion service at ${TOR_HOSTNAME}"
echo "[TOR] ==================================================================="
echo ""

bundle exec rails db:migrate

# Start Tor
"tor" -f "${APP_PATH}/config/torrc-dev" & bundle exec ${@}
# run passed commands
