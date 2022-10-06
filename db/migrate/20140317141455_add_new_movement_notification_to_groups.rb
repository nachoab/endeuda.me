class AddNewMovementNotificationToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :new_movement_notification, :boolean, default: false
  end
end
