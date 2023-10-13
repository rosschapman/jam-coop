# frozen_string_literal: true

Rails.application.routes.draw do
  get  'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create'

  get  'home', to: 'home#index'

  resources :sessions, only: %i[index show destroy]
  resource  :password, only: %i[edit update]
  namespace :identity do
    resource :email,              only: %i[edit update]
    resource :email_verification, only: %i[show create]
    resource :password_reset,     only: %i[new edit create update]
  end

  resources :interests, only: %i[new create] do
    member do
      get :confirm_email
    end
  end

  resources :artists do
    resources :albums, only: %i[show new edit create update] do
      member do
        patch 'publish'
        patch 'unpublish'
      end

      resources :tracks, only: %i[new edit create update destroy] do
        member do
          post 'move_higher'
          post 'move_lower'
        end
      end
    end
  end

  get 'thankyou', to: 'interests#thankyou'
  get 'confirmation', to: 'interests#confirmation'

  root 'interests#new'
end
