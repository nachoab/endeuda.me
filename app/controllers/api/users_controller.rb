class API::UsersController < Api::ApiController

  def show
    render :json => User.find(params[:id])
  end

  def index
    render :json => current_user
  end

  # Only own user updatable
  def update
    if current_user.id == user_params[:id]
      current_user.update_attributes(user_params)
      render :json => current_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :user_id, :name)
  end

end 