Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Health check mejorado que verifica dependencias
  get "health" => "health#show", as: :health_check

  # Rutas de auditoría
  resources :audit_logs, only: [:index, :show, :create]
  delete "audit_logs/cleanup", to: "audit_logs#cleanup"

  # Defines the root path route ("/")
  # root "posts#index"
end
