module SchemaBasedApiUser
    extend ActiveSupport::Concern
    
    included do
        def authenticate password
            self&.valid_password?(password) ? self : nil
        end

        ## DSL (AKA what to show in the returned JSON)

        ## CUSTOM ACTIONS
        # Here you can add custom actions to be called from the API
        # The action must return an serializable (JSON) object.

        # Here you can find an example *without* ID, in the API it could be called like this:
        # GET /api/v2/:controller?do=test&parameter=sample
        # def self.custom_action_test params=nil
        #     { test: [ :first, :second, :third ], params: params}
        # end

        # Here you can find an example *with* ID, in the API it could be called like this:
        # GET /api/v2/:controller/:id?do=test_with_id&parameter=sample
        # def self.custom_action_test_with_id id=nil, params=nil
        #     { test: [ :first, :second, :third ], id: id, params: params}
        # end
    end
end