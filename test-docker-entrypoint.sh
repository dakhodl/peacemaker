#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"


# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

# Check if we need to install new gems
bundle check || bundle install --jobs 20 --retry 5

redis-server &

# Then run any passed command
bundle exec foreman s -f Procfile.integration