class API::GroupsController < Api::ApiController

  def index
    render :json => current_user.groups
  end

  def update
    if groups_params[:users] && groups_params[:users].length > 1
      Group.transaction(isolation: :serializable) do
        @group = current_user.groups.find(groups_params[:id])
        @group.name = groups_params[:name]
        @group.new_movement_notification = groups_params[:new_movement_notification]
        groupUsersId = @group.user.map(&:id)

        groups_params[:users].each do |key, value|
          @user = User.find(key[:user_id])

          if @user && !groupUsersId.include?(@user.id)
            @group.user << @user

            # Sent email with notification
            Notifications.added_to_group_notification(@group, current_user, @user).deliver

            # Add to him all the movements of this group so he can see them
            Movement.where(:group => @group) do |movement|
              movement.shareholders.create(:user => @user)
            end
          end
        end

        @group.save
        render :json => @group
      end
    end
  end

  def create
    if groups_params[:users] && groups_params[:users].length > 0

      Group.transaction(isolation: :serializable) do
        @group = current_user.groups.build(:name => groups_params[:name], :new_movement_notification => groups_params[:new_movement_notification], :owner => current_user)
        @group.save
        current_user_found = false

        groups_params[:users].each do |key, value|
          @user = User.find(key[:user_id])
          if @user
            @group.user << @user

            if @user.id == current_user.id
              current_user_found = true
            else
              # Sent email with notification
              Notifications.added_to_group_notification(@group, current_user, @user).deliver
            end

          end
        end

        if !current_user_found
          @group.user << current_user
        end

        render :json => @group
      end

    end
  end

private

  def groups_params
    params.require(:group).permit(:id, :name, :new_movement_notification, :users => [:user_id])
  end

end
