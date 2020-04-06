$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "schema_based_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "schema_based_api"
  spec.version     = SchemaBasedApi::VERSION
  spec.authors     = ["Gabriele Tassoni"]
  spec.email       = ["gabriele.tassoni@gmail.com"]
  spec.homepage    = "https://github.com/gabrieletassoni/schema_based_api"
  spec.summary     = "Convention based RoR engine which uses DB schema introspection to create REST APIs."
  spec.description = "Ruby on Rails REST APIs built by convention using the DB schema as the foundation."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.2", ">= 6.0.2.1"

  spec.add_dependency "thecore_auth_commons", "~> 2.1"
  spec.add_dependency "jwt", "~> 2.2"

  spec.add_dependency "simple_command", "~> 0.1"
  spec.add_dependency "kaminari", "~> 1.2"

  spec.add_dependency 'ransack', "~> 2.3"
  spec.add_dependency 'active_hash_relation', "~> 1.4"
  spec.add_dependency 'rack-cors', "~> 1.1"

  spec.add_dependency 'multi_json', '~> 1.14'

  spec.add_development_dependency "sqlite3"
end
