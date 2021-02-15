require 'rails_helper'

RSpec.describe Sector, type: :model do
  it { should belong_to(:event) }
  it { should have_many(:seats) }
end