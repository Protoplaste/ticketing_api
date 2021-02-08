class Reservation < ApplicationRecord
  has_many :tickets
  has_many :seats, through: :tickets
  has_one :payment

  validates :tickets, presence: true
  validate :even_ticket_number, if: -> { sector&.selling_option_even }
  validate :avoids_one_seat_left, if: -> { sector&.selling_option_avoid_one }
  validate :seats_next_to_each_other, if: -> { sector&.selling_option_all_together }

  def total_cost
    seats.map(&:cost).reduce(:+)
  end

  def sector
    tickets.first&.sector
  end

  private

  def even_ticket_number
    if tickets.length.odd?
      errors.add(:ticket_count, "cannot be an odd number in this sector")
    end
  end

  def avoids_one_seat_left
    if (sector.seats.count - tickets.length == 1)
      errors.add(:ticket_count, "cannot leave one seat empty in this sector")
    end
  end

  def seats_next_to_each_other
    seats = tickets.map(&:seat)
    if seats.map(&:row).uniq.length > 1
      errors.add(:seat_placement, "cannot reserve seats in different rows in this sector")
    end
  end
end
