# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :reservation
  belongs_to :seat
  has_one :sector, through: :seat

  validates :reservation_id, uniqueness: { scope: [:seat_id] }
end
