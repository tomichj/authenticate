if Authenticate.configuration.routes_enabled?
  Rails.application.routes.draw do
    resource :session, controller: 'authenticate/sessions', only: [:create, :new, :destroy]
    resources :passwords, controller: 'authenticate/passwords', only: [:new, :create]

    user_actions = Authenticate.configuration.allow_sign_up? ? [:new, :create] : []
    resource :users, controller: 'authenticate/users', only: user_actions do
      resources :passwords, controller: 'authenticate/passwords', only: [:edit, :update]
    end

    get '/sign_up', to: 'authenticate/users#new', as: 'sign_up'
    get '/sign_in', to: 'authenticate/sessions#new', as: 'sign_in'
    get '/sign_out', to: 'authenticate/sessions#destroy', as: 'sign_out'
  end
end
