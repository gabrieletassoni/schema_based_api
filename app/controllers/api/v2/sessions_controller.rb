class Api::V2::SessionsController < Devise::SessionsController
    # load_and_authorize_resource
    # TODO: Explore https://medium.com/@brentkearney/json-web-token-jwt-and-html-logins-with-devise-and-ruby-on-rails-5-9d5e8195193d
    respond_to :json
    
    private
    
    def respond_with(resource, _opts = {})
        render json: resource
    end
    
    def respond_to_on_destroy
        head :no_content
    end
end