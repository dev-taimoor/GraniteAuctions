Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  get 'home/index'
  post '/verification', to: 'users#verification', as: 'verification'
  get '/user_verification', to: 'users#user_verification', as: 'user_verification'
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  resources :cars

  resources :auctions

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
