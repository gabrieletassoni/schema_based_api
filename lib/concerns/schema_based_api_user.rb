module SchemaBasedApiUser
    extend ActiveSupport::Concern
    
    included do
        def authenticate pass
            true
        end

        # has_secure_password

        # def to_token_payload
        #     {
        #         sub: id,
        #         email: email
        #     }
        # end
    end
end