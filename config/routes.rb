Rails.application.routes.draw do
  resources :ads
  resources :peers

  namespace :api do
    namespace :v1 do
      resources :ads, only: [:get]
      post 'webhook', to: 'webhook#create'
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/ping', to: 'static#index'
  root to: 'peers#index'
end
