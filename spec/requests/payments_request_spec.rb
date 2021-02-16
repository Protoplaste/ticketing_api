# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  let(:reservation) { create(:reservation_with_tickets) }
  let(:status) { 'pending' }
  let!(:payment) { create(:payment, reservation: reservation, status: status) }
  let(:token) { :valid }
  let(:params) { { token: token } }
  let(:payment_id) { payment.id }

  describe 'put /payment/:payment_id/charge' do
    let(:request) { put "/payments/#{payment_id}/charge", params: params }

    context 'when payment goes through' do
      before { request }

      it 'returns correct amount paid' do
        expect(json['amount']).to eq reservation.total_cost
      end

      it 'updates payments status' do
        expect(Payment.last.status).to eq 'paid'
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when reservation timed out during payment' do
      before do
        ReservationTimeoutJob.perform_now(reservation)
        request
      end

      it 'redirects to refund process' do
        expect(request).to redirect_to(action: :refund, id: payment_id)
      end
    end

    context 'when payment not found' do
      let(:payment_id) { 0 }

      before { request }

      it 'returns an error' do
        expect(json['message']).to include("Couldn't find Payment")
      end
    end

    context 'when payment fails due to card error' do
      before { request }

      let(:token) { :card_error }

      it 'returns correct error message' do
        expect(json['message']).to eq 'Your card has been declined.'
      end

      it 'does not update payment status' do
        expect(Payment.last.status).to eq 'pending'
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when payment fails due to payment error' do
      before { request }

      let(:token) { :payment_error }

      it 'returns correct error message' do
        expect(json['message']).to eq 'Something went wrong with your transaction.'
      end

      it 'does not update payment status' do
        expect(Payment.last.status).to eq 'pending'
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'put /payment/:payment_id/refund' do
    let(:request) { put "/payments/#{payment_id}/refund", params: params }

    let(:status) { 'paid' }

    before { request }

    context 'when refund request is valid' do
      include_examples 'payment request refund success examples'
    end

    context 'when payment was not finalized' do
      let(:status) { 'pending' }

      include_examples 'payment refund request failure due to status examples'
    end

    context 'when payment was already refunded' do
      let(:status) { 'refunded' }

      include_examples 'payment refund request failure due to status examples'
    end

    context 'when payment refund failed before' do
      let(:status) { 'refund_failed' }

      include_examples 'payment request refund success examples'
    end

    context 'when payment gateway fails' do
      let(:token) { :refund_error }

      it 'changes payments status' do
        expect(Payment.last.status).to eq 'refund_failed'
      end

      it 'does not remove reservations' do
        expect(Payment.last.reservation.tickets.empty?).not_to be true
      end

      it 'returns correct error message' do
        expect(json['message']).to eq 'Something went wrong with the refund process'
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
