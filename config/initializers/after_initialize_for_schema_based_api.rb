require 'concerns/model_driven_api_user'
require 'concerns/model_driven_api_role'

Rails.application.configure do
    config.after_initialize do
        User.send(:include, ModelDrivenApiUser)
        Role.send(:include, ModelDrivenApiRole)
    end
end