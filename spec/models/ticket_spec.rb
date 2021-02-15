# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ticket, type: :model do
  subject { build(:ticket, reservation: reservation) }

  let(:reservation) { create(:full_reservation) }

  it { is_expected.to belong_to(:reservation) }
  it { is_expected.to belong_to(:seat) }
  it { is_expected.to have_one(:sector).through(:seat) }

  it { is_expected.to validate_uniqueness_of(:reservation_id).scoped_to(:seat_id) }
end
