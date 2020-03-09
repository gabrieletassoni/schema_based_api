$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "schema_based_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "schema_based_api"
  spec.version     = SchemaBasedApi::VERSION
  spec.authors     = [""]
  spec.email       = ["gabriele.tassoni@gmail.com"]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of SchemaBasedApi."
  spec.description = "TODO: Description of SchemaBasedApi."
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
  spec.add_dependency "thecore_auth", "~> 2.1"

  s.add_dependency 'ransack', "~> 2.3"
  s.add_dependency 'active_hash_relation', "~> 1.4"
  s.add_dependency 'rack-cors', "~> 1.1"
  # s.add_dependency 'therubyracer', "~> 0.12"

  spec.add_development_dependency "sqlite3"
end
