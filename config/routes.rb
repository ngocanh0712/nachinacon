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
  end
end
