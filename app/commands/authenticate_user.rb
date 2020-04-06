class AuthenticateUser
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
        unless user.present?
            errors.add :message, "Invalid email / password"
            return nil
        end
        
        # Verify the password. You can create a blank method for now.
        unless user.authenticate(password)
            errors.add :message, "Invalid email / password"
            return nil
        end
        
        return user
    end
    
end