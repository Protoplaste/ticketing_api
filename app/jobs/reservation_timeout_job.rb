class ReservationTimeoutJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    if reservation.payment.status != "paid"
      reservation.update_attribute(:status, "timeout")
      reservation.tickets.each do |ticket|
        ticket.destroy!
      end
    end
  end
end
