class AuthenticateUser
    class AccessDenied < StandardError
        def message
            "Cannot authenticate user."
        end
    end
    prepend SimpleCommand
    
    def initialize(email, password)
        @email = email
        @password = password
    end
    
    def call
        JsonWebToken.encode(user_id: api_user.id) if api_user
    end
    
    private
    
    attr_accessor :email, :password
    
    def api_user
        user = User.find_by_email(email)
        raise AccessDenied unless user.present?
        
        # Verify the password. You can create a blank method for now.
        raise AccessDenied if user.authenticate(password).blank?
        
        return user
    end
    
end