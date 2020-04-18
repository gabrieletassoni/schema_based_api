class Api::V2::AuthenticationController < ActionController::API
    include ::ApiExceptionManagement

    def authenticate
        command = AuthenticateUser.call(params[:auth][:email], params[:auth][:password])
        
        if command.success?
            response.headers['Token'] = command.result
            head :ok
        end
    end
end