class MovementSerializer < ActiveModel::Serializer
  attributes :id, :added_by, :group_id, :type, :title, :amount, :created_at, :updated_at
  has_many :shareholders
  # has_one :payer, serializer: customSerializer

  def added_by
    object.added_by.id
  end
end

# class customSerializer < ActiveModel::Serializer
#   attributes :user_id, :name, :uid
# end