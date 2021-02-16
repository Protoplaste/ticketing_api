# frozen_string_literal: true

class PaymentsController < ApplicationController
  require 'payment_adapter/gateway'
  include GatewayError

  before_action :fetch_payment, only: %i[charge refund]

  def charge
    response = Adapter::Payment::Gateway.charge(token: params[:token], amount: @payment.amount)
    process_payment

    # Checking for reservation status after processing payment to avoid racing condition with reservation timeout job
    if @payment.reservation.status == 'timeout'
      redirect_to :refund
    else
      json_response(response, :ok)
    end
  end

  def refund
    raise PaymentUnrefundable, @payment.status unless %w[paid refund_failed].include? @payment.status

    response = Adapter::Payment::Gateway.refund(token: params[:token],
                                                amount: @payment.amount,
                                                payment_id: @payment.id)
    process_refund
    json_response(response, :ok)
  end

  private

  def fetch_payment
    @payment = Payment.includes(reservation: [:tickets]).find(params[:id])
  end

  def process_payment
    @payment.set_paid
    @payment.save!
  end

  def process_refund
    @payment.set_refunded
    @payment.save!
    @payment.reservation.tickets.each(&:destroy)
  end
end
