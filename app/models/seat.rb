class Seat < ApplicationRecord
  has_one :ticket
  has_one :reservation, through: :ticket
  belongs_to :event
end
