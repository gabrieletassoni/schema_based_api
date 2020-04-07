class Api::V2::AuthenticationController < Api::V2::ApplicationController
    skip_load_and_authorize_resource
    skip_before_action :authenticate_request
    
    def authenticate
        command = AuthenticateUser.call(params[:auth][:email], params[:auth][:password])
        
        if command.success?
            render json: { token: command.result }
        else
            render json: { error: command.errors }, status: :unauthorized
        end
    end
    
end