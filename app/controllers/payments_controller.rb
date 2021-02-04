class PaymentsController < ApplicationController
  require 'payment_adapter/gateway'

  def update
    payment = Payment.find(params[:id])

    begin
      response = Adapter::Payment::Gateway.charge(token: params[:token], amount: payment.amount)
    rescue Adapter::Payment::Gateway::CardError, Adapter::Payment::Gateway::PaymentError => e
      json_response({ message: e.message }, :bad_request) and return
    end

    payment.set_paid
    payment.save!

    json_response(response, :ok)
  end

end
