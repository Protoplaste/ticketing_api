# frozen_string_literal: true

RSpec.shared_examples 'reservation request success examples' do
  it 'returns reservation id' do
    expect(json['id']).not_to be nil
  end

  it 'returns status code 201' do
    expect(response).to have_http_status(:created)
  end

  it 'creates a reservation' do
    expect(Reservation.last).not_to be nil
  end

  it 'creates tickets' do
    tickets = Reservation.last.tickets
    expect(tickets.empty?).not_to be true
    expect(tickets.length).to eq seats.length
  end

  it 'creates a pending payment' do
    payment = Reservation.last.payment
    expect(payment.status).to eq 'pending'
    expect(payment.amount).to eq payment.reservation.total_cost
  end

  it 'creates a timeout job' do
    expect(ReservationTimeoutJob).to have_been_enqueued
  end
end

RSpec.shared_examples 'reservation request failure examples' do
  it 'does not create a reservation' do
    expect(json['id']).to be nil
    expect(Reservation.last).to be nil
  end

  it 'does not create tickets' do
    expect(Ticket.all.empty?).to be true
  end

  it 'does not create a pending payment' do
    expect(Payment.last).to be nil
  end

  it 'does not create a timeout job' do
    expect(ReservationTimeoutJob).not_to have_been_enqueued
  end
end
