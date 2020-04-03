Warden::JWTAuth.configure do |config|
    suburi = "/api/v2"
    config.secret = Rails.application.secrets.secret_key_base
    config.dispatch_requests = [
        ['POST', %r{^#{suburi}/login$}],
        ['POST', %r{^#{suburi}/login.json$}]
    ]
    config.revocation_requests = [
        ['DELETE', %r{^#{suburi}/logout$}],
        ['DELETE', %r{^#{suburi}/logout.json$}]
    ]
end