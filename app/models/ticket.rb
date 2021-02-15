class Ticket < ApplicationRecord
  belongs_to :reservation
  belongs_to :seat
  has_one :sector, through: :seat

  validates_uniqueness_of :reservation_id, scope: [:seat_id]
end
