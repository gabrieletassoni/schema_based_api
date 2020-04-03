class Api::V2::InfoController < Api::V2::BaseController
  # Info uses a different auth method: username and password
  skip_before_action :authenticate_user!, only: [:version], raise: false

  # api :GET, '/api/v2/info/version', "Just prints the APPVERSION."
  # api!
  def version
    render json: {
      version: SchemaBasedApi::VERSION
    }.to_json, status: 200
  end

  # api :GET, '/api/v2/info/token'
  # it returns the AUTH_TOKEN, email and id of the user which performed the authentication."
  # api!
  # def token
  #   render json: {
  #     token: @current_user.authentication_token,
  #     email: @current_user.email
  #   }.to_json, status: 200
  # end

  # api :GET, '/api/v2/info/available_roles'
  # it returns the roles list
  def available_roles
    render json: ROLES.to_json, status: 200
  end

  # GET '/api/v2/info/translations'
  def translations
    render json: I18n.t(".", locale: (params[:locale].presence || :it)).to_json, status: 200
  end

  # GET '/api/v2/info/schema'
  def schema
    pivot = {}
    # if Rails.env.development?
    #   Rails.configuration.eager_load_namespaces.each(&:eager_load!) if Rails.version.to_i == 5 #Rails 5
    #   Zeitwerk::Loader.eager_load_all if Rails.version.to_i >= 6 #Rails 6
    # end
    ApplicationRecord.subclasses.each do |d|
      model = d.to_s.underscore.tableize
      pivot[model] ||= {}
      d.columns_hash.each_pair do |key, val| 
        pivot[model][key] = val.type unless key.ends_with? "_id"
      end
      # Only application record descendants to have a clean schema
      pivot[model][:associations] ||= {
        has_many: d.reflect_on_all_associations(:has_many).map { |a| 
          a.name if (((a.options[:class_name].presence || a.name).to_s.classify.constantize.new.is_a? ApplicationRecord) rescue false)
        }.compact, 
        belongs_to: d.reflect_on_all_associations(:belongs_to).map { |a| 
          a.name if (((a.options[:class_name].presence || a.name).to_s.classify.constantize.new.is_a? ApplicationRecord) rescue false)
        }.compact
      }
      pivot[model][:methods] ||= (d.instance_methods(false).include?(:json_attrs) && !d.json_attrs.blank?) ? d.json_attrs[:methods] : nil
    end
    render json: pivot.to_json, status: 200
  end

  # GET '/api/v2/info/dsl'
  def dsl
    pivot = {}
    # if Rails.env.development?
    #   Rails.configuration.eager_load_namespaces.each(&:eager_load!) if Rails.version.to_i == 5 #Rails 5
    #   Zeitwerk::Loader.eager_load_all if Rails.version.to_i >= 6 #Rails 6
    # end
    ApplicationRecord.subclasses.each do |d|
      model = d.to_s.underscore.tableize
      pivot[model] = (d.instance_methods(false).include?(:json_attrs) && !d.json_attrs.blank?) ? d.json_attrs : nil
    end
    render json: pivot.to_json, status: 200
  end
  # private

  # Method overridden because the first time I have to ask for the token
  # def authenticate_user!
  #   username, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
  #   if username
  #     user = User.find_by(username: username)
  #   end
  #   if user && user.valid_password?(password)
  #     @current_user = user
  #   else
  #     return unauthenticated!
  #   end
  # end
end
