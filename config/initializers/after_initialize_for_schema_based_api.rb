require 'concerns/schema_based_api_user'

Rails.application.configure do
    config.after_initialize do
        User.send(:include, SchemaBasedApiUser)
    end
end