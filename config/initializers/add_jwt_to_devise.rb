# Thanks to: https://medium.com/@brentkearney/json-web-token-jwt-and-html-logins-with-devise-and-ruby-on-rails-5-9d5e8195193d
Devise.setup do |config|
    # Secret Key
    config.jwt do |jwt|
        # TODO: Investigate
        # Important: You are encouraged to use a secret different than 
        # your application secret_key_base. 
        # It is quite possible that some other component of your system 
        # is already using it. If several components share the same secret 
        # key=begin  =end, chances that a vulnerability in one of them has a wider impact 
        # increase. In rails, generating new secrets is as easy as bundle exec 
        # rake secret. Also, never share your secrets pushing it to a remote 
        # repository, you are better off using an environment variable like in 
        # the example: ENV['DEVISE_JWT_SECRET_KEY'].
        jwt.secret = Rails.application.secrets.secret_key_base
        # The endpoint (URL/route) for logins, where devise-jwt will issue new 
        # authentication tokens. I want JSON users to visit /api/v2/login to 
        # authenticate.
        jwt.dispatch_requests = [
            ['POST', %r{^/login$}],
            ['POST', %r{^/login.json$}]
        ]
        # The endpoint for logouts, where devise-jwt will revoke authentication 
        # tokens.
        jwt.revocation_requests = [
            ['DELETE', %r{^/logout$}],
            ['DELETE', %r{^/logout.json$}]
        ]
        jwt.expiration_time = 1.day.to_i
        # The format of incoming requests that devise-jwt should pay attention to. 
        # In my app, I only want JSON web tokens to be issued for JSON requests 
        # (you could also add nil to the array, which means unspecified format). 
        # For HTML requests, I want users to go to the web interface at a different 
        # endpoint, “/signin”, so if someone visits /api/v2/login with an HTML 
        # request instead of JSON, I want devise-jwt to ignore it.
        jwt.request_formats = { api_user: [:json] 
    end
    config.navigational_formats = ['*/*', :html, :json]
end