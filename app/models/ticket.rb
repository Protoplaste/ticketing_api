# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :reservation
  belongs_to :seat
  has_one :sector, through: :seat

  validates :seat_id, uniqueness: { message: 'Seat already reserved' }
end
