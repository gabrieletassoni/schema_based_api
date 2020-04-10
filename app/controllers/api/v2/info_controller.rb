class Api::V2::InfoController < Api::V2::ApplicationController
  # Info uses a different auth method: username and password
  skip_before_action :authenticate_request, only: [:version], raise: false
  # Here we don't need CanCanCan, no ActiveRecord models here.
  skip_load_and_authorize_resource

  # api :GET, '/api/v2/info/version', "Just prints the APPVERSION."
  # api!
  def version
    render json: { version: SchemaBasedApi::VERSION }.to_json, status: 200
  end

  # api :GET, '/api/v2/info/roles'
  # it returns the roles list
  def roles
    render json: ::Role.all.to_json, status: 200
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
end
