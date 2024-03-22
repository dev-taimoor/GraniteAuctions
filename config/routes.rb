Rails.application.routes.draw do
  require 'sidekiq/web'
  get 'dashboard/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  get 'home/index'
  get '/car_collection', to: 'home#car_collection', as: 'car_collection'
  post '/verification', to: 'users#verification', as: 'verification'
  get '/user_verification', to: 'users#user_verification', as: 'user_verification'
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  
  resources :cars do
    post 'add_to_auction', on: :member
  end

  resources :auctions do
    get 'cars', on: :member
    delete 'delete_auction_car', on: :member
    collection do
      get 'all_auctions'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
  mount Sidekiq::Web => '/sidekiq'
end
