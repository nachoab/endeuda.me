class ShareholderSerializer < ActiveModel::Serializer
  attributes :user_id, :name, :uid, :provider, :avatar, :is_payer, :is_receiver

  def name
    object.user.name
  end

  def uid
    object.user.uid
  end

  def provider
    object.user.provider
  end

  def avatar
    object.user.avatar
  end
end