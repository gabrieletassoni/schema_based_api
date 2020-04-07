module SchemaBasedApiUser
    extend ActiveSupport::Concern
    
    included do
        def authenticate password
            self&.valid_password?(password) ? self : nil
        end
    end
end