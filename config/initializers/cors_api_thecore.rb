# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: %w(Token),
      methods: :any,
      expose: %w(Token),
      max_age: 600
  end
end
