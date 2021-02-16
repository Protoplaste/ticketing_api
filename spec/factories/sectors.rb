# frozen_string_literal: true

FactoryBot.define do
  factory :sector do
    name { 'A' }
    selling_option_even { false }
    selling_option_all_together { false }
    selling_option_avoid_one { false }
    event
    factory :sector_with_selling_options do
      selling_option_even { true }
      selling_option_all_together { true }
      selling_option_avoid_one { true }
    end
  end
end
