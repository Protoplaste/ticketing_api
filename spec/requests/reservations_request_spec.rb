require 'rails_helper'

RSpec.describe 'Reservations', type: :request do
  let(:sector) { create(:sector) }
  let!(:seats) { create_list(:seat, 2, sector: sector) }
  let(:seat_ids) { seats.map(&:id) }

  describe 'POST /reservations' do
    let(:params) { { seats: seat_ids } }

    context 'when the request is valid' do
      before { post '/reservations', params: params }

      include_examples "reservation request success examples"
    end

    context 'when trying to create an empty reservation' do
      before { post '/reservations', params: { } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a error message' do
        expect(response.body)
          .to match("message\":\"Couldn't find Seat without an ID")
      end

      include_examples "reservation request failure examples"
    end

    context 'when sector have enabled selling option' do
      context 'even' do
        let(:sector) { create(:sector, selling_option_even: true) }

        before { post '/reservations', params: params }

        it 'lets valid request through' do
          expect(response).to have_http_status(201)
        end

        context 'when trying to reserve odd number of tickets' do
          let!(:seats) { create_list(:seat, 3, sector: sector) }

          it 'returns error message' do
            expect(json["message"]).to eq "Validation failed: Ticket count cannot be an odd number in this sector"
          end

          include_examples "reservation request failure examples"
        end
      end

      context 'avoid one' do
        let(:sector) { create(:sector, selling_option_avoid_one: true) }
        let!(:additional_seats) {}

        before { post '/reservations', params: params }

        context 'when reservation leaves no seats left' do
          it 'lets valid request through' do
            expect(response).to have_http_status(201)
          end
        end

        context 'when reservation leaves more than one seat left' do
          let!(:additional_seats) { create_list(:seat, 2, sector: sector) }

          it 'lets valid request through' do
            expect(response).to have_http_status(201)
          end
        end

        context 'when reservation would leave one seat left' do
          let!(:additional_seats) { create(:seat, sector: sector) }

          it 'returns error message' do
            expect(json["message"]).to eq "Validation failed: Ticket count cannot leave one seat empty in this sector"
          end

          include_examples "reservation request failure examples"
        end
      end
    end
  end
end