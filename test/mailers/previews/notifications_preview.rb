class NotificationsPreview < ActionMailer::Preview

  def movement_created_notification
    Notifications.movement_created_notification(Movement.first, User.first, User.last)
  end

  def movement_deleted_notification
    Notifications.movement_deleted_notification(Movement.first, User.first, User.last)
  end

  def added_to_group_notification
    Notifications.added_to_group_notification(Group.first, User.first, User.last)
  end

end
