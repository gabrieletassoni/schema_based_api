class Api::V2::BaseController < ActionController::API
    include ActionController::MimeResponds
    
    respond_to :json
    
    include CanCan::ControllerAdditions
    #include Pundit
    #check_authorization
    #load_and_authorize_resource
    # https://github.com/kollegorna/active_hash_relation
    include ActiveHashRelation
    
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session, if: request.format.json?
    skip_before_action :verify_authenticity_token, if: request.format.json?
    
    before_action :destroy_session
    
    before_action :authenticate_user!
    before_action :set_current_user, if: :json_request?
    before_action :find_model#, except: [ :version, :available_roles, :translations, :schema ]
    before_action :find_record, only: [ :show, :update, :destroy ]
    
    rescue_from ActiveRecord::StatementInvalid, with: :unauthenticated!
    rescue_from ActiveRecord::RecordInvalid, with: :invalid!
    rescue_from CanCan::AccessDenied, with: :unauthorized!
    rescue_from ActiveRecord::RecordNotFound, with: :not_found!
    rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token
    # rescue_from NameError, with: :name_error!
    # rescue_from NoMethodError, with: :no_method_error!
    # rescue_from ::RubySpark::Device::ApiError, with: :fivehundred!
    
    attr_accessor :current_user
    
    # JWT: https://www.pluralsight.com/guides/token-based-authentication-with-ruby-on-rails-5-api
    
    #Disabling Strong Parameters
    # def params
    #   request.parameters
    # end
    
    def check
        # This method is only valid for ActiveRecords
        # For any other model-less controller, the actions must be 
        # defined in the route, and must exist in the controller definition.
        # So, if it's not an activerecord, the find model makes no sense at all
        # Thus must return 404
        path = params[:path].split("/")
        # puts "CHECK"
        return not_found! if (!path.first.classify.constantize.new.is_a? ActiveRecord::Base rescue false)
        find_model path.first
        if request.get?
            if path.second.blank?
                @page = params[:page]
                @per = params[:per]
                @pages_info = params[:pages_info]
                @count = params[:count]
                @query = params[:q]
                index
            elsif path.second.to_i.zero?
                # String, so it's a custom action I must find in the @model (as a singleton method)
                # GET :controller/:custom_action
                # puts "SECOND ZERO?"
                return not_found! unless @model.respond_to?(path.second)
                return render json: MultiJson.dump(@model.send(path.second, params)), status: 200
            elsif !path.second.to_i.zero? && path.third.blank?
                # Integer, so it's an ID, I must show it
                # Rails.logger.debug "IL SECONDO è ID? #{path.second.inspect}"
                # find_record path.second.to_i
                @record_id =  path.second.to_i
                find_record
                show
            elsif !path.second.to_i.zero? && !path.third.blank?
                # GET :controller/:id/:custom_action
                # puts "SECOND AND THIRD"
                return not_found! unless @model.respond_to?(path.third)
                return render json: MultiJson.dump(@model.send(path.third, path.second.to_i, params)), status: 200
            end
        elsif request.post?
            if path.second.blank?
                @params = params
                create
            elsif path.second.to_i.zero?
                # POST :controller/:custom_action
                # puts "NO SECOND"
                return not_found! unless @model.respond_to?(path.second)
                return render json: MultiJson.dump(@model.send(path.second, params)), status: 200
            end
        elsif request.put?
            if !path.second.to_i.zero? && path.third.blank?
                @params = params
                # Rails.logger.debug "IL SECONDO è ID in PUT? #{path.second.inspect}"
                # find_record path.second.to_i
                @record_id =  path.second.to_i
                find_record
                update
            elsif !path.second.to_i.zero? && !path.third.blank?
                # PUT :controller/:id/:custom_action
                # puts "ANOTHER SECOND AND THIRD"
                return not_found! unless @model.respond_to?(path.third)
                return render json: MultiJson.dump(@model.send(path.third, path.second.to_i, params)), status: 200
            end
        elsif request.delete?
            # Rails.logger.debug "IL SECONDO è ID in delete? #{path.second.inspect}"
            # find_record path.second.to_i
            @record_id =  path.second.to_i
            find_record
            destroy
        end
    end
    
    def index
        # Rails.logger.debug params.inspect
        # find the records
        @q = (@model.column_names.include?("user_id") ? @model.where(user_id: current_user.id) : @model).ransack(@query.presence|| params[:q])
        @records_all = @q.result(distinct: true)
        page = (@page.presence || params[:page])
        per = (@per.presence || params[:per])
        pages_info = (@pages_info.presence || params[:pages_info])
        count = (@count.presence || params[:count])
        @records = @records_all.page(page).per(per)
        
        # If there's the keyword pagination_info, then return a pagination info object
        return render json: MultiJson.dump({count: @records_all.count,current_page_count: @records.count,next_page: @records.next_page,prev_page: @records.prev_page,is_first_page: @records.first_page?,is_last_page: @records.last_page?,is_out_of_range: @records.out_of_range?,pages_count: @records.total_pages,current_page_number: @records.current_page }) if !pages_info.blank?
        
        # puts "ALL RECORDS FOUND: #{@records_all.inspect}"
        status = @records_all.blank? ? 404 : 200
        # puts "If it's asked for page number, then paginate"
        return render json: MultiJson.dump(@records, json_attrs), status: status if !page.blank? # (@json_attrs || {})
        #puts "if you ask for count, then return a json object with just the number of objects"
        return render json: MultiJson.dump({count: @records_all.count}) if !count.blank?
        #puts "Default"
        json_out = MultiJson.dump(@records_all, json_attrs)
        #puts "JSON ATTRS: #{json_attrs}"
        #puts "JSON OUT: #{json_out}"
        render json: json_out, status: status #(@json_attrs || {})
    end
    
    def search
        index
        render :index
    end
    
    def show
        result = @record.to_json(json_attrs)
        render json: result, status: 200
    end
    
    def create
        @record =  @model.new(request_params)
        @record.user_id = current_user.id if @model.column_names.include? "user_id"
        
        @record.save!
        
        render json: @record.to_json(json_attrs), status: 201
    end
    
    def update
        @record.update_attributes!(request_params)
        
        render json: @record.to_json(json_attrs), status: 200
    end
    
    def destroy
        return api_error(status: 500) unless @record.destroy
        # render json: {message: "Deleted"}, status: 200
        head :ok
    end
    
    protected
    
    def destroy_session
        request.session_options[:skip] = true
    end
    
    def unauthenticated!
        response.headers['WWW-Authenticate'] = "Token realm=Application"
        # render json: { error: 'bad credentials' }, status: 401
        api_error status: 401, errors: [I18n.t("api.errors.bad_credentials", default: "Bad Credentials")]
    end
    
    def unauthorized!
        # render nothing: true, status: :forbidden
        api_error status: 403, errors: [I18n.t("api.errors.unauthorized", default: "Unauthorized")]
        return
    end
    
    def not_found!
        return api_error(status: 404, errors: [I18n.t("api.errors.not_found", default: "Not Found")])
    end
    
    def name_error!
        api_error(status: 501, errors: [I18n.t("api.errors.name_error", default: "Name Error")])
    end
    
    def no_method_error!
        api_error(status: 501, errors: [I18n.t("api.errors.no_method_error", default: "No Method Error")])
    end
    
    def invalid! exception
        # puts "ISPEZIONI: #{exception.record.errors.inspect}"
        # render json: { error: exception }, status: 422
        api_error status: 422, errors: exception.record.errors
    end
    
    def fivehundred!
        api_error status: 500, errors: [I18n.t("api.errors.fivehundred", default: "Internal Server Error")]
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
    
    def paginate(resource)
        resource = resource.page(params[:page] || 1)
        if params[:per_page]
            resource = resource.per_page(params[:per_page])
        end
        
        return resource
    end
    
    # expects pagination!
    def meta_attributes(object)
        {
            current_page: object.current_page,
            next_page: object.next_page,
            prev_page: (object.previous_page rescue nil),
            total_pages: object.total_pages,
            total_count: (object.total_entries rescue nil)
        }
    end
    
    def authenticate_user!
        token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
        
        user_email = options.blank? ? nil : options[:email]
        user = User.find_by(email: user_email)
        
        return unauthenticated! if user.blank? || !ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
        @current_user = user
    end
    
    def find_record
        # find the records
        @record = @model.column_names.include?("user_id") ? @model.where(id: (@record_id.presence || params[:id]), user_id: current_user.id).first : @model.find((@record_id.presence || params[:id]))
        return not_found! if @record.blank?
    end
    
    def find_model path=nil
        # Find the name of the model from controller
        path ||= (params[:path].split("/").first rescue nil)
        @model = (path.presence || controller_path).classify.constantize rescue controller_name.classify.constantize rescue nil
    end
    
    def request_params
        (@params.presence || params).require(params[:path].split("/").first.singularize.to_sym).permit!
    end
    
    def json_attrs
        ((@model.json_attrs.presence || @json_attrs.presence || {}) rescue {})
    end
    
    private
    
    # Use api_user Devise scope for JSON access
    # def authenticate_user!(*args)
    #     super and return unless args.blank?
    #     request.format.json? ? authenticate_api_user! : super
    # end
    def invalid_auth_token
        respond_to do |format|
            format.html { redirect_to sign_in_path,  error: 'Login invalid or expired' }
            format.json { head 401 }
        end
    end
    # So we can use Pundit policies for api_users
    # def set_current_user
    #     @current_user ||= warden.authenticate(scope: :user)
    # end
end
