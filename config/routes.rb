# require 'ransack'

Rails.application.routes.draw do
    # REST API (Stateless)
    namespace :api, constraints: { format: :json } do
        namespace :v2 do
            resources :users

            namespace :info do
                get :version
                get :roles
                get :translations
                get :schema
                get :dsl
            end

            post "authenticate" => "authentication#authenticate"
            post ":ctrl/search" => 'application#index'

            # Catchall routes
            # match '*path', to: "application#default", via: :all
            # # CRUD Show
            get '*path/:id/:custom_action', to: 'application#show'#, constraints: lambda { |request| 
            get '*path/:id', to: 'application#show'#, constraints: lambda { |request| 
            # # CRUD Index
            get '*path', to: 'application#index' #, constraints: lambda { |request| request.path.split("/").second.blank? }
            # # CRUD Create
            post '*path', to: 'application#create'#, constraints: lambda { |request| path.second.blank? }
            # # CRUD Update
            put '*path/:id/:custom_action', to: 'application#update'#, constraints: lambda { |request| 
            put '*path/:id', to: 'application#update'#, constraints: lambda { |request| 
            # # CRUD DElete
            delete '*path/:id', to: 'application#destroy'
        
            
            # Catchall routes
            # # # # GET :controller/:custom_action
            # # # get '*path', to: 'base#custom_index', constraints: lambda { |request| request.path.split("/").second.to_i.zero? }
           # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && path.third.blank? 
            # # # }
            # # # # GET :controller/:id/:custom_action
            # # # get '*path', to: 'base#custom_show', constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && !path.third.blank?
            # # # }
            # # # # POST :controller/:custom_action
            # # # post '*path', to: 'base#custom_create', constraints: lambda { |request| path.second.to_i.zero? }
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && path.third.blank?
            # # # }
            # # # PUT :controller/:id/:custom_action
            # # put '*path', to: 'base#custom_update'#, constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && !path.third.blank?
            # # # }
        end
    end
end
