class ReservationsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      #find seats that user wants to reserve
      seats = Seat.includes(:sector).find(params[:seats])

      #create the reservation for those seats
      @reservation = Reservation.new
      seats.each do |seat|
        @reservation.tickets << Ticket.new(seat: seat)
      end
      @reservation.save!
      
      #prepare payment
      Payment.create!(reservation: @reservation, amount: @reservation.total_cost)
      #Create a job to remove the reservation if it's not paid for in 15 minutes
      ReservationTimeoutJob.set(wait: 15.minutes).perform_later(@reservation)
    end
    
    json_response(@reservation, :created)
  end
end