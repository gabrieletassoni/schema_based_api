class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_user!
  def create
    user = User.find_by(email: request_params[:email])
    if user && user.authenticate(request_params[:password])
      self.current_user = user
      render(
        json: Api::V1::SessionSerializer.new(user, root: false).to_json,
        status: 201
      )
    else
      return api_error(status: 401)
    end
  end

  private
  
  def request_params
    params.require(:user).permit(:email, :password)
  end
end