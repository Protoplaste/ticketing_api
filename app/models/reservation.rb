class Reservation < ApplicationRecord
  has_many :tickets
  has_many :seats, through: :tickets
  has_one :payment

  def total_cost
    seats.map(&:cost).reduce(:+)
  end
end
