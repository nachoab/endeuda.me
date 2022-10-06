class Shareholder < ActiveRecord::Base
  belongs_to :movement
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => [:movement_id]
end
