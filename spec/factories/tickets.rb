# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    seat
    reservation
  end
end
