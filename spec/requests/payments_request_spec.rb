# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments', type: :request do
  let!(:reservation) { create(:full_reservation) }

  describe 'put /payment/:payment_id' do
    let(:token) { 'valid' }
    let(:payment_id) { reservation.payment.id }
    let(:params) { { token: token } }

    before { put "/payments/#{payment_id}", params: params }

    context 'when payment goes through' do
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
        put "/payments/#{payment_id}", params: params
      end

      it 'processes a refund' do
        expect(json['transaction_type']).to eq 'refund'
      end

      it 'sets payment status to refunded' do
        expect(Payment.last.status).to eq 'refunded'
      end
    end

    context 'when payment not found' do
      let(:payment_id) { 0 }

      it 'returns an error' do
        expect(json['message']).to include("Couldn't find Payment")
      end
    end

    context 'when payment fails' do
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
end
