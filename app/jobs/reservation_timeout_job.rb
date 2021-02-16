# frozen_string_literal: true

class ReservationTimeoutJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    return unless reservation.payment.status != 'paid'

    reservation.update(status: 'timeout')
    reservation.tickets.each(&:destroy!)
  end
end
