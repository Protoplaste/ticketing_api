# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sector, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to have_many(:seats) }
end
