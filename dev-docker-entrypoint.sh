#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

# ensure hidden service folder has correct perms for tor
chmod 0700 /var/app/hidden_service/

# Generate a new hs_ed25519_secret_key, hs_ed5519_public_key, and hostname if both were not specified
if [ ! -f "${APP_PATH}/hidden_service/hs_ed25519_secret_key" ] || [ ! -f "${APP_PATH}/hidden_service/hs_ed25519_public_key" ] || [ ! -f "${APP_PATH}/hidden_service/hostname" ]; then
    echo "[TOR] WARNING: hs_ed25519_secret_key, hs_ed25519_public_key, and/or hostname were not specified"
    echo "[TOR] WARNING: Attempting to generate a new hs_ed25519_secret_key, hs_ed25519_public_key, and hostname"

    # Ensure that hs_ed25519_secret_key, hs_ed5519_public_key, and hostname files are really gone
    rm -f "${APP_PATH}/hidden_service/hs_ed25519_secret_key" "${APP_PATH}/hidden_service/hs_ed5519_public_key" "${APP_PATH}/hidden_service/hostname"

    # Start Tor in the background and track the PID
    tor -f "${APP_PATH}/config/torrc-dev" & TOR_PID=$!

    # Wait until hs_ed25519_secret_key, hs_ed5519_public_key, and hostname are generated then kill Tor (for now)
    TOR_AUTOGEN_TRIES_REMAINING=5
    while [ ! -f "${APP_PATH}/hidden_service/hs_ed25519_secret_key" ] && [ ! -f "${HOME}/hidden_service/hs_ed25519_public_key" ] && [ ! -f "${HOME}/hidden_service/hostname" ]; do
        TOR_AUTOGEN_TRIES_REMAINING=$((TOR_AUTOGEN_TRIES_REMAINING-1))
        if [ $TOR_AUTOGEN_TRIES_REMAINING -eq 0 ]; then
            echo "[TOR] FAILURE: Unable to generate a hs_ed25519_secret_key, hs_ed25519_public_key, and hostname"
            exit 1
        fi
        sleep 1
    done
    kill $TOR_PID
    echo "[TOR] Successfully generated new hs_ed25519_secret_key, hs_ed25519_public_key, and hostname"
fi

#!/usr/bin/env bash
set -eo pipefail

bundle exec rails db:migrate

# Start Tor
bundle exec ${@}
# run passed commands
