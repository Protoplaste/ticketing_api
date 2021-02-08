class Ticket < ApplicationRecord
  belongs_to :reservation
  belongs_to :seat
  has_one :sector, through: :seat
end
