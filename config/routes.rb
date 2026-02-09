# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Public pages
  root 'pages#home'
  get 'timeline', to: 'pages#timeline'
  get 'milestones', to: 'pages#milestones'
  get 'albums', to: 'pages#albums'
  get 'albums/:id', to: 'pages#album', as: :album_detail
  get 'search', to: 'pages#search'
  get 'memories/:id', to: 'pages#memory', as: :memory_detail
  post 'memories/:id/react', to: 'reactions#create', as: :memory_react
  get 'memories/:id/reactions', to: 'reactions#index', as: :memory_reactions

  # Fun & Interactive
  get 'vui-choi', to: 'pages#games', as: :games_hub
  get 'then-vs-now', to: 'pages#then_vs_now'
  get 'spin-wheel', to: 'pages#spin_wheel'
  post 'spin-wheel/spin', to: 'pages#spin'

  # Games
  namespace :games do
    get 'memory', to: 'memory#index'
    post 'memory/start', to: 'memory#start'
    post 'memory/complete', to: 'memory#complete'
    get 'guess-age', to: 'guess_age#index'
    post 'guess-age/start', to: 'guess_age#start'
    post 'guess-age/check', to: 'guess_age#check_answer'
    post 'guess-age/complete', to: 'guess_age#complete'
  end

  # Admin authentication
  get 'admin/login', to: 'sessions#new', as: :admin_login
  post 'admin/login', to: 'sessions#create'
  delete 'admin/logout', to: 'sessions#destroy', as: :admin_logout

  # Admin panel
  namespace :admin do
    root 'dashboard#index'
    resources :memories
    resources :milestones
    resources :albums
    get 'settings', to: 'settings#index'
    patch 'settings', to: 'settings#update'
    get 'system/cloudinary', to: 'system#cloudinary_status', as: :cloudinary_status
  end
end
