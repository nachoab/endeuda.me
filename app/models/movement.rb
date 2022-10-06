class Movement < ActiveRecord::Base
  belongs_to :added_by, :class_name => 'User'
  belongs_to :group
  has_many :shareholders, :dependent => :destroy

  # enum type: [ :expense, :transfer ]
  validates :type,
    :inclusion  => { :in => [ 'expense', 'transfer' ],
    :message    => "%{value} is not a valid type" }

  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  
  accepts_nested_attributes_for :shareholders

  # type columns auto subclass disabled
  self.inheritance_column = :_type_disabled
end