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
    attr_reader :payment_id

    def initialize(payment_id)
      super
      @payment_id = payment_id
    end

    def message
      'Something went wrong with the refund process'
    end
  end

  class PaymentUnrefundable < GatewayError
    attr_reader :status

    def initialize(status)
      super
      @status = status
    end

    def message
      "Cannot refund payment with status #{status}"
    end
  end
end
