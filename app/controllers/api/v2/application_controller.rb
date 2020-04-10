class Api::V2::ApplicationController < ActionController::API
    include ActiveHashRelation
    
    before_action :authenticate_request
    before_action :extract_model
    before_action :find_record, only: [ :show, :destroy, :update ]
    
    attr_accessor :current_user
    
    # Actions will be authorized directly in the action
    include CanCan::ControllerAdditions
    
    rescue_from NoMethodError, with: :not_found!
    rescue_from CanCan::AccessDenied, with: :unauthorized!
    rescue_from AuthenticateUser::AccessDenied, with: :unauthenticated!
    rescue_from ActionController::RoutingError, with: :not_found!
    rescue_from ActiveModel::ForbiddenAttributesError, with: :fivehundred!
    rescue_from ActiveRecord::RecordInvalid, with: :invalid!
    rescue_from ActiveRecord::RecordNotFound, with: :not_found!
    
    # Nullifying strong params for API
    def params
        request.parameters
    end
    
    # TODO: Remove when not needed
    # def dispatcher
    #     # This method is only valid for ActiveRecords
    #     # For any other model-less controller, the actions must be 
    #     # defined in the route, and must exist in the controller definition.
    #     # So, if it's not an activerecord, the find model makes no sense at all.
    #     path = params[:path].split("/")
    #     # Default convention for the requests: :controller/:id/:custom_action
    #     # or :controller/:custom_action.
    #     # With the ID as an Integer
    #     # TODO: Extend to understand nested resources maybe testing if the 
    #     # third param is a AR model, that can have an ID, etc..
    #     controller = path.first
    #     id = path.second
    #     custom_action = path.third
    #     # managing 
    #     if request.get?
    #         if id.blank?
    #             # @page = params[:page]
    #             # @per = params[:per]
    #             # @pages_info = params[:pages_info]
    #             # @count = params[:count]
    #             # @query = params[:q]
    #             index
    #         elsif id.to_i.zero?
    #             # String, so it's a custom action I must find in the @model (as a singleton method)
    #             # GET :controller/:custom_action
    #             return not_found! unless @model.respond_to?(id)
    #             return render json: MultiJson.dump(@model.send(id, params)), status: 200
    #         elsif !id.to_i.zero? && custom_action.blank?
    #             # Integer, so it's an ID, I must show it
    #             @record_id =  id.to_i
    #             find_record
    #             show
    #         elsif !id.to_i.zero? && !custom_action.blank?
    #             # GET :controller/:id/:custom_action
    #             return not_found! unless @model.respond_to?(custom_action)
    #             return render json: MultiJson.dump(@model.send(custom_action, id.to_i, params)), status: 200
    #         end
    #     elsif request.post?
    #         if id.blank?
    #             # @params = params
    #             create
    #         elsif id.to_i.zero?
    #             # POST :controller/:custom_action
    #             return not_found! unless @model.respond_to?(id)
    #             return render json: MultiJson.dump(@model.send(id, params)), status: 200
    #         end
    #     elsif request.put?
    #         if !id.to_i.zero? && custom_action.blank?
    #             # @params = params
    #             # Rails.logger.debug "IL SECONDO è ID in PUT? #{path.second.inspect}"
    #             # find_record path.second.to_i
    #             @record_id =  id.to_i
    #             find_record
    #             update
    #         elsif !id.to_i.zero? && !custom_action.blank?
    #             # PUT :controller/:id/:custom_action
    #             # puts "ANOTHER SECOND AND THIRD"
    #             return not_found! unless @model.respond_to?(custom_action)
    #             return render json: MultiJson.dump(@model.send(custom_action, id.to_i, params)), status: 200
    #         end
    #     elsif request.delete?
    #         # Rails.logger.debug "IL SECONDO è ID in delete? #{path.second.inspect}"
    #         # find_record path.second.to_i
    #         @record_id =  id.to_i
    #         find_record
    #         destroy
    #     end
    # end
    
    # GET :controller/
    def index
        authorize! :index, @model
        # Rails.logger.debug params.inspect
        # find the records
        @q = (@model.column_names.include?("user_id") ? @model.where(user_id: current_user.id) : @model).ransack(@query.presence|| params[:q])
        @records_all = @q.result(distinct: true)
        page = (@page.presence || params[:page])
        per = (@per.presence || params[:per])
        pages_info = (@pages_info.presence || params[:pages_info])
        count = (@count.presence || params[:count])
        # Paging
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
    
    def show
        authorize! :show, @record
        result = @record.to_json(json_attrs)
        render json: result, status: 200
    end
    
    def create
        @record = @model.new(@body)
        authorize! :create, @record
        @record.user_id = current_user.id if @model.column_names.include? "user_id"
        
        @record.save!
        
        render json: @record.to_json(json_attrs), status: 201
    end
    
    def update
        authorize! :update, @record
        @record.update_attributes!(@body)
        
        render json: @record.to_json(json_attrs), status: 200
    end
    
    def destroy
        authorize! :destroy, @record
        return api_error(status: 500) unless @record.destroy
        head :ok
    end
    
    private
    
    def authenticate_request
        @current_user = AuthorizeApiRequest.call(request.headers).result
        unauthenticated! unless @current_user
        current_user = @current_user
    end
    
    # 
    # before_action :find_record, only: [ :show, :destroy, :update ]
    
    # # # https://github.com/kollegorna/active_hash_relation
    # include ActiveHashRelation
    
    # # Prevent CSRF attacks by raising an exception.
    # # For APIs, you may want to use :null_session.
    # protect_from_forgery with: :null_session
    
    # def custom_index
    #     return not_found! unless @model.respond_to?(path.second)
    #     return render json: MultiJson.dump(@model.send(path.second, params)), status: 200
    # end
    
    # # GET :controller/:id/:custom_action
    # def custom_show
    #     return not_found! unless @model.respond_to?(path.third)
    #     return render json: MultiJson.dump(@model.send(path.third, path.second.to_i, params)), status: 200
    # end
    
    # # POST :controller/:custom_action
    # def custom_create
    #     return not_found! unless @model.respond_to?(path.second)
    #     return render json: MultiJson.dump(@model.send(path.second, params)), status: 200
    # end
    
    # # PUT :controller/:id/:custom_action
    # def custom_update
    #     return not_found! unless @model.respond_to?(path.third)
    #     return render json: MultiJson.dump(@model.send(path.third, path.second.to_i, params)), status: 200
    # end
    
    
    
    
    
    
    
    
    # private
    
    def find_record
        # find the records
        record_id ||= (params[:path].split("/").second.to_i rescue nil)
        @record = @model.column_names.include?("user_id") ? @model.where(id: (record_id.presence || @record_id.presence || params[:id]), user_id: current_user.id).first : @model.find((@record_id.presence || params[:id]))
        return not_found! if @record.blank?
    end
    
    def json_attrs
        ((@model.json_attrs.presence || @json_attrs.presence || {}) rescue {})
    end
    
    def extract_model
        # This method is only valid for ActiveRecords
        # For any other model-less controller, the actions must be 
        # defined in the route, and must exist in the controller definition.
        # So, if it's not an activerecord, the find model makes no sense at all
        # thus must return 404.
        @model = (params[:ctrl].classify.constantize rescue params[:path].split("/").first.classify.constantize rescue controller_path.classify.constantize rescue controller_name.classify.constantize rescue nil)
        # Getting the body of the request if it exists, it's ok the singular or 
        # plural form, this helps with automatic tests with Insomnia.
        @body = params[@model.model_name.singular].presence || params[@model.model_name.route_key]
        # Only ActiveRecords can have this model caputed 
        return not_found! if (!@model.new.is_a? ActiveRecord::Base rescue false)
    end
    
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
