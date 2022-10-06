class Group < ActiveRecord::Base
  has_and_belongs_to_many :user, :uniq => true
  has_many :movements
  belongs_to :owner, :class_name => :User
end
