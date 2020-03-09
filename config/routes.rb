require 'ransack'

Rails.application.routes.draw do
    # REST API (Stateless)
    namespace :api do
        namespace :v1, defaults: { format: :json } do
            namespace :info do
                get :version
                get :available_roles
                get :translations
                get :schema
                get :dsl
            end
            
            resources :users, only: [:index, :create, :show, :update, :destroy] do
                match 'search' => 'users#search', via: [:get, :post], as: :search, on: :collection
            end
            
            namespace :base do
                get :check
                post :check
                put :check
                delete :check
            end
            
            # Catchall routes
            get '*path', to: 'base#check'
            post '*path', to: 'base#check'
            put '*path', to: 'base#check'
            delete '*path', to: 'base#check'
        end
    end
end
