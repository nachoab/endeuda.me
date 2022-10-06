class ContactSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :provider, :uid, :avatar, :updated_at
  attribute :contact_id, key: :user_id

  def name
    object.contact.name
  end

  def email
    object.contact.email
  end

  def provider
    object.contact.provider
  end

  def avatar
    object.contact.avatar
  end

  def uid
    object.contact.uid
  end
end