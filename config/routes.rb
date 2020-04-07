# require 'ransack'

Rails.application.routes.draw do
    # REST API (Stateless)
    namespace :api do
        namespace :v2, defaults: { format: :json } do
            resources :users

            post "authenticate" => "authentication#authenticate"
            
            # # # Catchall routes
            # # get '*path', to: 'base#index' #, constraints: lambda { |request| request.path.split("/").second.blank? }
            # # # # GET :controller/:custom_action
            # # # get '*path', to: 'base#custom_index', constraints: lambda { |request| request.path.split("/").second.to_i.zero? }
            # # get '*path', to: 'base#show'#, constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && path.third.blank? 
            # # # }
            # # # # GET :controller/:id/:custom_action
            # # # get '*path', to: 'base#custom_show', constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && !path.third.blank?
            # # # }
            # # post '*path', to: 'base#create'#, constraints: lambda { |request| path.second.blank? }
            # # # # POST :controller/:custom_action
            # # # post '*path', to: 'base#custom_create', constraints: lambda { |request| path.second.to_i.zero? }
            # # put '*path', to: 'base#update'#, constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && path.third.blank?
            # # # }
            # # # PUT :controller/:id/:custom_action
            # # put '*path', to: 'base#custom_update'#, constraints: lambda { |request| 
            # # #     path = request.path.split("/")
            # # #     !path.second.to_i.zero? && !path.third.blank?
            # # # }
            # # delete '*path', to: 'base#destroy'
        end
    end
end
