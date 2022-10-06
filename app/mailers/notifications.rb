class Notifications < ActionMailer::Base
  default from: "endeuda.me <notifications@endeuda.me>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.movement_deleted.subject
  #
  def movement_created_notification(movement, addedby, shareholder)
    @movement = movement
    @addedby = addedby
    @shareholder = shareholder
    mail to: @shareholder.email, subject: "#{@addedby.name} added the #{@movement.amount}€ #{@movement.type} '#{@movement.title}' on endeudame"
  end

  def movement_deleted_notification(movement, deletedby, user)
    @movement = movement
    @deletedby = deletedby
    @user = user
    mail to: @user.email, subject: "#{@deletedby.name} has deleted the movement '#{@movement.title}' on endeudame"
  end

  def added_to_group_notification(group, inviter, invited)
    @group = group
    @inviter = inviter
    @invited = invited
    mail to: @invited.email, subject: "#{@inviter.name} has invited you to share expenses in the group #{@group.name} on endeudame"
  end

end
