# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  let(:reservation) { create(:reservation_with_tickets) }
  let(:status) { 'pending' }
  let!(:payment) { create(:payment, reservation: reservation, status: status) }
  let(:payment_id) { payment.id }
  let(:token) { 'valid' }
  let(:params) { { token: token } }

  describe 'put /payment/:payment_id/charge' do

    subject { put "/payments/#{payment_id}/charge", params: params }

    context 'when payment goes through' do
      before { subject }

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
        subject
      end

      it 'redirects to refund process' do
        expect(subject).to redirect_to(action: :refund, id: payment_id)
      end
    end

    context 'when payment not found' do
      let(:payment_id) { 0 }

      before { subject }

      it 'returns an error' do
        expect(json['message']).to include("Couldn't find Payment")
      end
    end

    context 'when payment fails' do
      before { subject }

      context 'due to card error' do
        let(:token) { 'card_error' }

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

      context 'due to payment error' do
        let(:token) { 'payment_error' }

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
  end

  describe 'put /payment/:payment_id/refund' do
    let(:status) { 'paid' }

    subject { put "/payments/#{payment_id}/refund", params: params }

    before { subject }

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
