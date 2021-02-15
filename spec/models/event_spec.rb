require 'rails_helper'

RSpec.describe Event, type: :model do
  it { should have_many(:sectors) }
end