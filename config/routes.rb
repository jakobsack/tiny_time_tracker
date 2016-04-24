Rails.application.routes.draw do
  resources :sessions
  resources :projects do
    collection do
      get :dashboard
    end
    resources :records do
      collection do
        post 'open'
      end
      member do
        post 'close'
      end
    end
  end

  root 'projects#dashboard'
end