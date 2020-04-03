# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: %w(Authorization),
      methods: :any,
      expose: %w(Authorization),
      max_age: 600
  end
  # allow do
  #   origins '*'
  #   resource '*',
  #     headers: :any,
  #     methods: %i(get post put patch delete options head)
  # end
end
