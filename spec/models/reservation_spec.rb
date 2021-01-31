require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it { should have_many(:tickets) }
  it { should have_one(:payment) }
end
