class PaymentsController < ApplicationController
  require 'payment_adapter/gateway'

  def update
    payment = Payment.find(params[:id])

    response = Adapter::Payment::Gateway.charge(token: params[:token], amount: payment.amount)

    payment.set_paid
    payment.save!

    json_response(response, :ok)
  end

end
