module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from GatewayError::GatewayError do |e|
      if e.class == GatewayError::RefundError
        payment = Payment.find(e.payment_id)
        payment.set_refund_failed
        payment.save!
      end
      json_response({ message: e.message }, :bad_request)
    end
  end
end