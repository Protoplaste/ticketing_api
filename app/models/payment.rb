class Payment < ApplicationRecord
  enum status: { pending: 0, paid: 1 }
  belongs_to :reservation
end
