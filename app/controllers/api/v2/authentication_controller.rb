class Api::V2::AuthenticationController < Api::V2::ApplicationController
    # No authentication for the request, it just needs the username and password
    skip_before_action :authenticate_request
    # Here we don't need CanCanCan, no ActiveRecord models here.
    skip_load_and_authorize_resource
    
    def authenticate
        command = AuthenticateUser.call(params[:auth][:email], params[:auth][:password])
        
        if command.success?
            render json: { token: command.result }
        else
            render json: { error: command.errors }, status: :unauthorized
        end
    end
    
end