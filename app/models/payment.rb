class Payment < ApplicationRecord
  enum status: { pending: 0, paid: 1 }
  belongs_to :reservation

  validates_presence_of :amount, :status
end
