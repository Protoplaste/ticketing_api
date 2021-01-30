FactoryBot.define do
  factory :seat do
    sector { "A" }
    row { "B" }
    number { |n| n }
    event
  end
end