# frozen_string_literal: true

class ReservationsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      # Find seats that user wants to reserve
      seats = Seat.includes(:sector).find(params[:seats])

      # Build a reservation with those seats
      @reservation = Reservation.new
      seats.each do |seat|
        @reservation.tickets << Ticket.new(seat: seat)
      end

      @reservation.transaction do
        @reservation.save!

        # Prepare payment
        Payment.create!(reservation: @reservation, amount: @reservation.total_cost)
        # Create a job to remove the reservation in 15 minutes if it's not paid for
        ReservationTimeoutJob.set(wait: 15.minutes).perform_later(@reservation)
      end
    end

    json_response(@reservation, :created)
  end
end
