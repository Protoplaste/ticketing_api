# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReservationTimeoutJob, type: :job do
  let(:payment_status) { Payment.statuses[:pending] }
  let(:reservation) { create(:reservation_with_tickets) }
  let(:payment) { create(:payment, reservation: reservation, status: payment_status) }

  before do
    payment
    described_class.perform_now(reservation)
  end

  context 'when reservation is paid for' do
    let(:payment_status) { Payment.statuses[:paid] }

    it 'does not update the reservation status' do
      expect(Reservation.last.status).not_to eq 'timeout'
    end

    it 'does not destroy reservations tickets' do
      expect(Ticket.first).not_to be nil
    end
  end

  context 'when reservation is not paid for' do
    it 'updates the reservation status' do
      expect(Reservation.last.status).to eq 'timeout'
    end

    it 'destroys reservations tickets' do
      expect(Ticket.first).to be nil
    end
  end
end
