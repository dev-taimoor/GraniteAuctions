Rails.application.routes.draw do
  require 'sidekiq/web'
  get 'dashboard/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :users do
    post 'approve_user', on: :member
    post 'reject_user', on: :member
    get 'preview', on: :member
  end

  get 'home/index'
  get '/car_collection', to: 'home#car_collection', as: 'car_collection'
  get '/car_search', to: 'home#car_search', as: 'car_search'
  post '/verification', to: 'users#verification', as: 'verification'
  get '/user_verification', to: 'users#user_verification', as: 'user_verification'
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  get '/car_purchase', to: 'cars#car_purchase', as: 'car_purchase'
  get '/successful_bid', to: 'cars#successful_bid', as: 'successful_bid'
  resources :cars do
    post 'add_to_auction', on: :member
    post 'buy'
    post 'submit_bid'
    get 'highest_bid'
  end

  scope module: 'payments' do
    get 'create_checkout_session'
    get 'subscription'
  end

  # scope module: 'bids' do
  #   get 'highest_bid'
  #   get 'subscription'
  # end

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
