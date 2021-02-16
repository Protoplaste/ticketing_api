# frozen_string_literal: true

class ReservationsController < ApplicationController
  before_action :fetch_seats, only: [:create]

  def create
    # Build a reservation for seats
    @reservation = Reservation.new
    @seats.each do |seat|
      @reservation.tickets << Ticket.new(seat: seat)
    end

    save_reservation

    json_response(@reservation, :created)
  end

  private

  def fetch_seats
    @seats = Seat.includes(:sector).find(params[:seats])
  end

  def save_reservation
    @reservation.transaction do
      @reservation.save!

      # Prepare payment
      Payment.create!(reservation: @reservation, amount: @reservation.total_cost)
      # Create a job to remove the reservation in 15 minutes if it's not paid for
      ReservationTimeoutJob.set(wait: 15.minutes).perform_later(@reservation)
    end
  end
end
