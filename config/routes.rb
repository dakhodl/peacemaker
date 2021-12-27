Rails.application.routes.draw do
  resources :ads
  resources :peers

  namespace :api do
    namespace :v1 do
      resources :ads, only: [:get]
      post 'webhook', to: 'webhook#create'
      get 'webhook/:uuid/:token', to: 'webhook#show'
      get 'status', to: 'status#show'
    end
  end

  root to: 'peers#index'
end
