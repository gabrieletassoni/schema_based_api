module ApiExceptionManagement
    extend ActiveSupport::Concern
    
    included do
        rescue_from NoMethodError, with: :not_found!
        rescue_from CanCan::AccessDenied, with: :unauthorized!
        rescue_from AuthenticateUser::AccessDenied, with: :unauthenticated!
        rescue_from ActionController::RoutingError, with: :not_found!
        rescue_from ActiveModel::ForbiddenAttributesError, with: :fivehundred!
        rescue_from ActiveRecord::RecordInvalid, with: :invalid!
        rescue_from ActiveRecord::RecordNotFound, with: :not_found!
        
        def unauthenticated! exception = StandardError.new
            response.headers['WWW-Authenticate'] = "Token realm=Application"
            api_error status: 401, errors: [I18n.t("api.errors.bad_credentials", default: "Bad Credentials"), exception.message]
        end
        
        def unauthorized! exception = StandardError.new
            api_error status: 403, errors: [I18n.t("api.errors.unauthorized", default: "Unauthorized"), exception.message]
            return
        end
        
        def not_found! exception = StandardError.new
            return api_error(status: 404, errors: [I18n.t("api.errors.not_found", default: "Not Found"), exception.message])
        end
        
        def name_error!
            api_error(status: 501, errors: [I18n.t("api.errors.name_error", default: "Name Error")])
        end
        
        def no_method_error!
            api_error(status: 501, errors: [I18n.t("api.errors.no_method_error", default: "No Method Error")])
        end
        
        def invalid! exception = StandardError.new
            api_error status: 422, errors: exception.record.errors
        end
        
        def fivehundred! exception = StandardError.new
            api_error status: 500, errors: [I18n.t("api.errors.fivehundred", default: "Internal Server Error"), exception.message]
        end
        
        def api_error(status: 500, errors: [])
            # puts errors.full_messages if !Rails.env.production? && errors.respond_to?(:full_messages)
            head status && return if errors.empty?
            
            # For retrocompatibility, I try to send back only strings, as errors
            errors_response = if errors.respond_to?(:full_messages) 
                # Validation Errors
                errors.full_messages.join(", ")
            elsif errors.respond_to?(:error)
                # Generic uncatched error
                errors.error
            elsif errors.respond_to?(:exception)
                # Generic uncatchd error, if the :error property does not exist, exception will
                errors.exception
            elsif errors.is_a? Array
                # An array of values, I like to have them merged
                errors.join(", ")
            else
                # Uncatched Error, comething I don't know, I must return the errors as it is
                errors
            end
            render json: {error: errors_response}, status: status
        end
    end
end