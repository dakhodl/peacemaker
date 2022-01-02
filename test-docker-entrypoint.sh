#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"


# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server-$INTEGRATION_SPECS.pid
echo "deleted $APP_PATH/tmp/pids/server-$INTEGRATION_SPECS.pid"

# Check if we need to install new gems
bundle check || bundle install --jobs 20 --retry 5

# systemctl start redis
redis-server &

bundle exec rake db:migrate
bundle exec rake db:seed

# Then run any passed command
exec "$@"