FactoryBot.define do
  factory :sector do
    name { "A" }
    selling_option_even { false }
    selling_option_all_together { false }
    selling_option_avoid_one { false }
    event
  end
end
