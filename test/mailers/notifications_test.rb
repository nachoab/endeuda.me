require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  test "movement_deleted_notification" do
    mail = Notifications.movement_deleted_notification
    assert_equal "Movement deleted", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
