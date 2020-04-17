class Api::V2::AuthenticationController < ActionController::API
    include ::ApiExceptionManagement

    def authenticate
        command = AuthenticateUser.call(params[:auth][:email], params[:auth][:password])
        
        if command.success?
            response.headers['Token'] = command.result
            render json: { message: ["Login successful!"] }
        else
            render json: { error: command.errors }, status: :unauthorized
        end
    end
    
end