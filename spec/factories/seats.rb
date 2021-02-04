FactoryBot.define do
  factory :seat do
    sector { "A" }
    row { "B" }
    number { |n| n }
    cost { rand(10..100) }
    event
  end
end