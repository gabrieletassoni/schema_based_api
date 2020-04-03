module ThecoreUserConcern
    extend ActiveSupport::Concern
    
    included do
        # A null object pattern strategy, which does not revoke tokens, 
        # is provided out of the box just in case you are absolutely sure 
        # you don't need token revocation. It is recommended not to use it.
        devise :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
        # If you still need the session for any other purpose, disable :database_authenticatable user storage
        self.skip_session_storage = [:http_auth, :params_auth]
        
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