# frozen_string_literal: true

module GatewayError
  class GatewayError < StandardError; end

  class CardError < GatewayError
    def message
      'Your card has been declined.'
    end
  end

  class PaymentError < GatewayError
    def message
      'Something went wrong with your transaction.'
    end
  end

  class RefundError < GatewayError
    attr_reader :payment

    def initailze(payment)
      super
      @payment = payment
    end

    def message
      'Something went wrong with the refund process'
    end
  end
end
