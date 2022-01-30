source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails'
# Use Puma as the app server
gem 'puma'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use SCSS for stylesheets
# gem 'sassc-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Talking to other nodes
gem 'ed25519' # for signing requests to other nodes
gem 'tor_requests', github: 'dakhodl/tor_requests'

# CSS framework
gem 'tailwindcss-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# How long can we get away with sqlite instead of postgres
# This is a one-machine, one-user application.
# A single peer could have a lot of chatter going on.
# They could queue up in redis or... just use postgres with a larger conn pool.
gem 'sqlite3'

# pagination
gem 'kaminari'

# background job processing
gem 'sidekiq'
gem 'sidekiq-cron'

# easy environment configuration
gem 'configatron'

# showing times in user tz
gem 'local_time'

# native linking https://github.com/ffi/ffi/issues/881
gem "ffi", github: "ffi/ffi", submodules: true

# crypto libsodium for SimpleBox message signing
gem 'rbnacl'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'

  gem 'capybara'
  gem 'factory_bot'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webmock'
end

group :test do
  gem 'rspec-sidekiq'
  gem 'foreman' # to run a hive of dockerized peers for end to end test
  gem 'capybara-screenshot'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen'
  gem 'rack-mini-profiler'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rubocop'
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
