Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }

  Sidekiq::Cron::Job.create(
    name: 'Peer status check - every 5min',
    cron: '*/5 * * * *',
    class: 'PeerStatusCheckJob'
  ) unless ENV['INTEGRATION_SPECS'] # execute at every 10 minutes, ex: 12:00, 12:10, 12:20...etc
  Sidekiq::Testing.disable! if ENV['INTEGRATION_SPECS']
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  Sidekiq::Testing.disable! if ENV['INTEGRATION_SPECS']
end
