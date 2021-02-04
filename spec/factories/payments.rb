FactoryBot.define do
  factory :payment do
    reservation
    amount { reservation.total_cost }
    status { 0 }
  end
end