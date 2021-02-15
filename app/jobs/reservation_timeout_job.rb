# frozen_string_literal: true

class ReservationTimeoutJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    if reservation.payment.status != 'paid'
      reservation.update_attribute(:status, 'timeout')
      reservation.tickets.each(&:destroy!)
    end
  end
end
