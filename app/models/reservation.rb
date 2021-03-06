# frozen_string_literal: true

class Reservation < ApplicationRecord
  has_many :tickets, dependent: :destroy
  has_many :seats, through: :tickets
  has_one :payment, dependent: :nullify

  validates :tickets, presence: true, on: :create
  validate :even_ticket_number, if: -> { selling_option_even? }
  validate :avoids_one_seat_left, if: -> { selling_option_avoid_one? }
  validate :seats_next_to_each_other, if: -> { selling_option_all_together? }

  def total_cost
    seats.map(&:cost).reduce(:+)
  end

  def sector
    tickets.first&.sector
  end

  private

  def selling_option_even?
    sector&.selling_option_even
  end

  def even_ticket_number
    errors.add(:ticket_count, 'cannot be an odd number in this sector') if tickets.length.odd?
  end

  def selling_option_avoid_one?
    sector&.selling_option_avoid_one
  end

  def avoids_one_seat_left
    errors.add(:ticket_count, 'cannot leave one seat empty in this sector') if sector.seats.count - tickets.length == 1
  end

  def selling_option_all_together?
    sector&.selling_option_all_together
  end

  def seats_next_to_each_other
    seats = tickets.map(&:seat)
    return unless seats.map(&:row).uniq.length > 1

    errors.add(:seat_placement, 'cannot reserve seats in different rows in this sector')
  end
end
