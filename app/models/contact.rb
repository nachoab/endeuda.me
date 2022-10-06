class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User'
  validates_uniqueness_of :user_id, :scope => :contact_id
end
