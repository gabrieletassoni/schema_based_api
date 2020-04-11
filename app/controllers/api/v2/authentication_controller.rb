class Api::V2::AuthenticationController < ActionController::API
    include ::ApiExceptionManagement

    def authenticate
        command = AuthenticateUser.call(params[:auth][:email], params[:auth][:password])
        
        if command.success?
            render json: { token: command.result }
        else
            render json: { error: command.errors }, status: :unauthorized
        end
    end
    
end