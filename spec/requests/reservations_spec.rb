require 'rails_helper'

RSpec.describe 'Reservations', type: :request do
  let(:event) { create(:event) }
  let!(:seats) { create_list( :seat, 3, event: event) }
  let(:seat_ids) { seats.map { |s| s.id } }

  describe 'POST /reservations' do
    let(:valid_attributes) { { seats: seat_ids } }

    context 'when the request is valid' do

      before { post '/reservations', params: valid_attributes }

      it 'creates a reservation' do
        expect(json["id"]).to_not be nil
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
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
    end
  end
end