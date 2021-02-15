# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    reservation
    status { Payment.statuses[:pending] }

    before :create do |payment|
      payment.amount = payment.reservation.total_cost
    end
  end
end
