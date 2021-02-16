# frozen_string_literal: true

class PaymentsController < ApplicationController
  require 'payment_adapter/gateway'
  include GatewayError

  def charge
    payment = Payment.find(params[:id])

    response = Adapter::Payment::Gateway.charge(token: params[:token], amount: payment.amount)

    payment.set_paid
    payment.save!

    # Checking for reservation status after processing payment to avoid racing condition with reservation timeout job
    if payment.reservation.status == 'timeout'
      redirect_to :refund
    else
      json_response(response, :ok)
    end
  end

  def refund
    payment = Payment.includes(reservation: [:tickets]).find(params[:id])

    if %w[paid refund_failed].include? payment.status
      response = Adapter::Payment::Gateway.refund(token: params[:token],
                                                  amount: payment.amount,
                                                  payment_id: payment.id)
      payment.set_refunded
      payment.save!
      payment.reservation.tickets.each(&:destroy)

      json_response(response, :ok)
    else
      raise PaymentUnrefundable, payment.status
    end
  end
end
