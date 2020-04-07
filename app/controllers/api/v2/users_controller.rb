class Api::V2::UsersController < Api::V2::ApplicationController #Api::V2::BaseController
  before_action :check_demoting, only: [ :update, :destroy ]
  
  private
  
  def check_demoting
    unauthorized! StandardError.new("You cannot demote yourself") if (params[:id].to_i == current_user.id && (params[:user].keys.include?("admin") || params[:user].keys.include?("locked")))
  end
  
  def request_params
    params.require(:user).permit!.delete_if{ |_,v| v.nil? }
  end
end
