# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reservations', type: :request do
  let(:sector) { create(:sector) }
  let!(:seats) { create_list(:seat, 2, sector: sector) }

  describe 'POST /reservations' do
    let(:params) { { seats: seats.map(&:id) } }
    let!(:additional_seats) {}

    before { post '/reservations', params: params }

    context 'when the request is valid' do
      include_examples 'reservation request success examples'
    end

    context 'when trying to create an empty reservation' do
      let(:params) { {} }

      it 'returns status code 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a error message' do
        expect(response.body)
          .to match("message\":\"Couldn't find Seat without an ID")
      end

      include_examples 'reservation request failure examples'
    end

    context 'when trying to reserve seats that are already reserved' do
      let!(:reservation) { create(:full_reservation) }
      let!(:seats) { reservation.seats }

      it 'returns validation error message' do
        expect(json['message']).to include 'Tickets is invalid'
      end

      it 'does not create a reservation' do
        expect(Reservation.count).to eq 1
      end

      it 'does not create tickets' do
        expect(Ticket.count).to eq seats.count
      end

      it 'does not create a pending payment' do
        expect(Payment.count).to eq 1
      end

      it 'does not create a timeout job' do
        expect(ReservationTimeoutJob).not_to have_been_enqueued
      end
    end

    describe 'sector selling option even' do
      let(:sector) { create(:sector, selling_option_even: true) }

      it 'lets reservation with even number of seats through' do
        expect(response).to have_http_status(:created)
      end

      context 'when trying to reserve odd number of tickets' do
        let!(:seats) { create_list(:seat, 3, sector: sector) }

        it 'returns error message' do
          expect(json['message']).to eq 'Validation failed: Ticket count cannot be an odd number in this sector'
        end

        include_examples 'reservation request failure examples'
      end
    end

    describe 'sector selling option avoid one' do
      let(:sector) { create(:sector, selling_option_avoid_one: true) }

      context 'when reservation leaves no seats left' do
        it 'lets reservation through' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when reservation leaves more than one seat left' do
        let!(:additional_seats) { create_list(:seat, 2, sector: sector) }

        it 'lets reservation through' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when reservation would leave one seat left' do
        let!(:additional_seats) { create(:seat, sector: sector) }

        it 'returns error message' do
          expect(json['message']).to eq 'Validation failed: Ticket count cannot leave one seat empty in this sector'
        end

        include_examples 'reservation request failure examples'
      end
    end

    describe 'sector selling option all together' do
      let(:sector) { create(:sector, selling_option_all_together: true) }

      it 'lets reservation with all seats in one row through' do
        expect(response).to have_http_status(:created)
      end

      context 'when reserving seats in defferent rows' do
        let(:rows) { %w[A B] }
        let!(:seats) do
          seats = []
          rows.each do |row|
            seats << create(:seat, sector: sector, row: row)
          end
          seats
        end

        it 'returns error message' do
          expect(json['message']).to eq 'Validation failed: Seat placement cannot reserve seats in different rows in this sector'
        end

        include_examples 'reservation request failure examples'
      end
    end
  end
end
