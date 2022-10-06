class API::MovementsController < Api::ApiController

  def index
    # Expensive
    render :json => Movement.joins("RIGHT JOIN shareholders ON shareholders.movement_id = movements.id")
                            .where(:shareholders => { :user_id => current_user.id })
                            # .where('S.user_id = ?', current_user.id)
  end

  def create
    Movement.transaction(isolation: :serializable) do

      @movement = Movement.new(movement_params)
      @movement.added_by = current_user

      if @movement.save
        @group = @movement.group

        if @group.new_movement_notification
          @group.user.each do |shareholder|
            if shareholder.id != current_user.id
              # Sent email with notification to everyone involved in the movement (not everyone in the group)
              Notifications.movement_created_notification(@movement, current_user, shareholder).deliver
            end
          end
        end

        # Update group timestamp and add all users to the movement so they see it
        if @group
          users_in_group = @group.user.map(&:id)
          users_in_group.each do |id|
            @movement.shareholders.create(:user_id => id)
          end
          @group.updated_at = DateTime.now
          @group.save

        # Not a group, add all people who now has debts (payer-shareholders)
        else
          # Find the payer
          @payer = nil
          movement_params[:shareholders_attributes].each do |user_params|
            is_payer = user_params[:is_payer]
            @user = User.find user_params[:user_id]

            if is_payer
              @payer = @user
            end

            # Sent email with notification to everyone but me.
            if @user.id != current_user.id
              Notifications.movement_created_notification(@movement, current_user, @user).deliver
            end
          end

          if @payer
            # Add payer-shareholder y shareholder-payer to contacts and update their timestamp.
            # They should always be friends.
            movement_params[:shareholders_attributes].each do |user_params|
              user_id = user_params[:user_id]
              if user_id != @payer.id
                @shareholder = User.find user_id
                @contactAB = Contact.where(:user => @shareholder, :contact => @payer).first_or_create
                @contactBA = Contact.where(:user => @payer, :contact => @shareholder).first_or_create
                if !@group
                  @contactAB.updated_at = DateTime.now
                  @contactBA.updated_at = DateTime.now
                end
                @contactAB.save
                @contactBA.save
              end
            end
          end
        end

        render :json => @movement
      end
      
    end
  end

  def update
    @movement = Movement.find(params.require(:movement).require(:id))
    @trip = current_user.trips.find(@movement.trip_id)

    if @trip
      @movement.update_attributes(movement_update_params)
      notify(@trip.id.to_s, {
        :key => 'movement.update',
        :owner_id => current_user.id,
        # :object => @vote
      });
    end

    # TODO: @movement ahora tiene shareholders MAL, duplicados. si lo consulto otra vez esta bien pq la 
    # db esta bien
    render :json => Movement.find(params.require(:movement).require(:id))
  end

  # Destroy if he is involved in any way.
  def destroy
    @movement = Movement.find(params.require(:id))
    isShareholder = @movement.shareholders.find_by(:user => current_user)

    if isShareholder
      @movement.shareholders.each do |shareholder|
        Notifications.movement_deleted_notification(@movement, current_user, shareholder.user).deliver
      end
      render :json => @movement.destroy
    end
  end

  private

  def movement_params
    params.require(:movement).permit(:title, :amount, :type, :group_id, :shareholders_attributes => [:user_id, :is_payer, :is_receiver])
  end

  def movement_update_params
    params.require(:movement).permit(:title, :amount, :type)
  end

end 
