require 'concerns/schema_based_api_user'
require 'concerns/schema_based_api_role'

Rails.application.configure do
    config.after_initialize do
        User.send(:include, SchemaBasedApiUser)
        Role.send(:include, SchemaBasedApiRole)
    end
end