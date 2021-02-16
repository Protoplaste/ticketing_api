# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Seat, type: :model do
  it { is_expected.to belong_to(:sector) }
  it { is_expected.to have_one(:ticket) }
  it { is_expected.to have_one(:reservation).through(:ticket) }
end
