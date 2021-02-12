# PAYMENT ADAPTER

# frozen_string_literal: true
module Adapter
  module Payment
    class Gateway
      include GatewayError
      Result = Struct.new(:amount, :currency, :transaction_type)

      class << self
        def charge(amount:, token:, currency: "EUR")
          case token.to_sym
          when :card_error
            raise GatewayError::CardError
          when :payment_error
            raise GatewayError::PaymentError
          else
            Result.new(amount, currency, :payment)
          end
        end

        def refund(amount:, token:, payment_id:, currency: "EUR")
          case token.to_sym
          when :refund_error
            raise GatewayError::RefundError.new(payment_id)
          else
            Result.new(amount, currency, :refund)
          end
        end
      end
    end
  end
end