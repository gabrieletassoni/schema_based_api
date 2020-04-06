class JsonWebToken
    class << self
      def encode(payload, expiry = 24.hours.from_now)
        payload[:expiry] = expiry.to_i
        secret_key_base = Rails.application.secrets.secret_key_base
        JWT.encode(payload, secret_key_base)
      end
      
      def decode(token)
        secret_key_base = Rails.application.secrets.secret_key_base
        body = JWT.decode(token, secret_key_base)[0]
        HashWithIndifferentAccess.new body
      rescue
        nil
      end
    end
  end