require 'sidekiq/web'

Rails.application.routes.draw do
  resources :messages
  resources :ads do
    member do
      resources :messages, as: :ad_messages
    end
  end
  resources :peers
  get '/marketplace', to: "marketplace#index"

  namespace :api do
    namespace :v1 do
      resources :ads, only: [:get]
      post 'webhook', to: 'webhook#create'
      get 'webhook/:uuid/:token', to: 'webhook#show'
      get 'status', to: 'status#show'
    end
  end

  # Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  #   # Protect against timing attacks:
  #   # - See https://codahale.com/a-lesson-in-timing-attacks/
  #   # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
  #   # - Use & (do not use &&) so that it doesn't short circuit.
  #   # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
  #   ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
  #     ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  # end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  root to: 'peers#index'
end
