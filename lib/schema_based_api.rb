require "schema_based_api/engine"

require 'thecore_auth_commons'
require 'active_hash_relation'
require 'rack/cors'
require 'ransack'
require 'json_web_token'
require "kaminari"
require "multi_json"
require "simple_command"

require 'concerns/api_exception_management'

require 'deep_merge/rails_compat'

module SchemaBasedApi
  def self.smart_merge src, dest
      src.deeper_merge! dest, {
          extend_existing_arrays: true, 
          merge_hash_arrays: true
      }
      src
  end
end
