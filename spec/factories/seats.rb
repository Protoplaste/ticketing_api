FactoryBot.define do
  factory :seat do
    sector
    row { "B" }
    number { |n| n }
    cost { rand(10..100) }
  end
end