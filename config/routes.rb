Rails.application.routes.draw do
  devise_for :users
  get "dashboard" => "dashboard#index"
  resources :opportunities
  resources :interview_sessions
  resources :resource_sheets do
    collection do
      post :generate_from_opportunity
    end
  end
  get "resources/guides/behavioral" => "resource_sheets#behavioral_guide", as: :behavioral_guide
  get "resources/guides/technical" => "resource_sheets#technical_guide", as: :technical_guide
  get "resources/guides/interviewer-questions" => "resource_sheets#interviewer_questions_guide", as: :interviewer_questions_guide
  get "resources/guides/acquired-questions" => "resource_sheets#acquired_questions_guide", as: :acquired_questions_guide
  resources :resource_guide_questions, except: %i[index show]
  resources :contacts
  resources :companies
  resources :star_stories
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest and service worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Signed-in users land on the dashboard; visitors see the sign-in page
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end
  devise_scope :user do
    root "devise/sessions#new"
  end
end
