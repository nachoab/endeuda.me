class UserSerializer < ActiveModel::Serializer
  attributes :email, :name, :provider, :avatar, :uid
  attribute :id, key: :userId
end