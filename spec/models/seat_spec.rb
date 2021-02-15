require 'rails_helper'

RSpec.describe Seat, type: :model do
  it { should belong_to(:sector) }
  it { should have_one(:ticket) }
  it { should have_one(:reservation).through(:ticket) }
end