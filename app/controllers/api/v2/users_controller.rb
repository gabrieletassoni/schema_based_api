class Api::V2::UsersController < Api::V2::BaseController
  load_and_authorize_resource
  # before_action :authenticate_user!
  
  before_action :check_demoting, only: [:update, :destroy]

  private
  
  def check_demoting
    render json: "You cannot demote yourself", status: 403 if (params[:id].to_i == current_user.id && (params[:user].keys.include?("admin") || params[:user].keys.include?("locked")))
  end
  
  def request_params
    params.require(:user).permit(:email, :roles, :password, :password_confirmation, :username, :number_of_instances_purchased, :admin, :locked).delete_if{ |_,v| v.nil? }
  end
end
