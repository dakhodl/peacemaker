Rails.application.routes.draw do
  resources :peers
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/ping', to: 'static#index'
  root to: 'peers#index'
end
