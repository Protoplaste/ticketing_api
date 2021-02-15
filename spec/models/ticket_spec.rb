require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:reservation) { create(:full_reservation) }
  subject { build(:ticket, reservation: reservation) }
  
  it { should belong_to(:reservation) }
  it { should belong_to(:seat) }
  it { should have_one(:sector).through(:seat) }

  it { should validate_uniqueness_of(:reservation_id).scoped_to(:seat_id) }
end