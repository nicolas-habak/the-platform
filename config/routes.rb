Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  post "/login", to: "sessions#create"
  namespace :api do
    resources :users
    resources :providers
    resources :employers do
      resources :divisions
      resources :policies
      resources :employees do
        resources :core_profiles
        resources :insurance_profiles
        resources :dependants
      end
    end
  end
end
