class PaymentsController < ApplicationController
  require 'payment_adapter/gateway'

  def update
    payment = Payment.find(params[:id])

    response = Adapter::Payment::Gateway.charge(token: params[:token], amount: payment.amount)

    payment.set_paid
    payment.save!

    if payment.reservation.status == "timeout"
      response = Adapter::Payment::Gateway.refund(token: params[:token],
                                                  amount: payment.amount,
                                                  payment_id: payment.id)
      payment.set_refunded
      payment.save!
    end

    json_response(response, :ok)
  end
end
