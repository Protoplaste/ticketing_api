# frozen_string_literal: true

class Payment < ApplicationRecord
  enum status: { pending: 0, paid: 1, refunded: 2, refund_failed: 3 }
  belongs_to :reservation

  validates :amount, :status, presence: true

  def set_paid
    self.status = Payment.statuses[:paid]
  end

  def set_refunded
    self.status = Payment.statuses[:refunded]
  end

  def set_refund_failed
    self.status = Payment.statuses[:refund_failed]
  end
end
