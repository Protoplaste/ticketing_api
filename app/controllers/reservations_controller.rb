class ReservationsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      @reservation = Reservation.create!(reservation_params)
      Seat.find(params[:seats]).each do |seat|
        Ticket.create!(seat: seat, reservation: @reservation)
      end
      Payment.create!(reservation: @reservation, amount: @reservation.total_cost)
    end
    
    json_response(@reservation, :created)
  end

  private

  def reservation_params
    params.permit()
  end
end