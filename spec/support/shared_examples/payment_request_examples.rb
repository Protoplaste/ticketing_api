# frozen_string_literal: true

RSpec.shared_examples 'payment request refund success examples' do
  it 'changes payment status' do
    expect(Payment.last.status).to eq 'refunded'
  end

  it 'removes reservations' do
    expect(Payment.last.reservation.tickets.empty?).to be true
  end

  it 'returns status code 200' do
    expect(response).to have_http_status(:ok)
  end

  it 'returns correct amount refunded' do
    expect(json['amount']).to eq reservation.total_cost
  end
end

RSpec.shared_examples 'payment refund request failure due to status examples' do
  it 'does not change payment status' do
    expect(Payment.last.status).to eq status
  end

  it 'does not remove reservations' do
    expect(Payment.last.reservation.tickets.empty?).not_to be true
  end

  it 'returns correct error message' do
    expect(json['message']).to eq "Cannot refund payment with status #{status}"
  end

  it 'returns status code 400' do
    expect(response).to have_http_status(:bad_request)
  end
end
