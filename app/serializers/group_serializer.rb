class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :owner_id, :new_movement_notification
  has_many :user, key: :users

end