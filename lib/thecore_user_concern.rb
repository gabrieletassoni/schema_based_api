module ThecoreUserConcern
    extend ActiveSupport::Concern
    
    included do
        # A null object pattern strategy, which does not revoke tokens, 
        # is provided out of the box just in case you are absolutely sure 
        # you don't need token revocation. It is recommended not to use it.
        devise :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
        
        def generate_jwt
            JWT.encode({ id: id, exp: 5.days.from_now.to_i }, Rails.env.devise.jwt.secret_key)
        end
        # Overrides
        # If you need to add something to the JWT payload, you can do it 
        # defining a jwt_payload method in the user model. It must return 
        # a Hash. For instance:
        # def jwt_payload
        #     super.merge(foo: 'bar')
        # end
        
        # Overrides
        # You can add a hook method on_jwt_dispatch on the user model. 
        # It is executed when a token dispatched for that user instance, 
        # and it takes token and payload as parameters.
        # def on_jwt_dispatch(token, payload)
        #     do_something(token, payload)
        # end
    end
end