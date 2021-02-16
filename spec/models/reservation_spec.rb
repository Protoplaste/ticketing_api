# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it { is_expected.to have_many(:tickets).dependent(:destroy) }
  it { is_expected.to have_many(:seats).through(:tickets) }
  it { is_expected.to have_one(:payment) }

  it { is_expected.to validate_presence_of(:tickets) }

  context 'selling options validations' do
    error_messages = { odd_seat_number: 'Ticket count cannot be an odd number in this sector',
                       one_seat_left_empty: 'Ticket count cannot leave one seat empty in this sector',
                       seats_separated: 'Seat placement cannot reserve seats in different rows in this sector' }
    # Prepare reservation that fails all selling option validations
    subject { build(:full_reservation, seats: seats) }

    let(:sector) { create(:sector_with_selling_options) }
    let(:rows) { %w[A B C] }
    let!(:seats) do
      s = []
      rows.each do |row|
        s << create(:seat, sector: sector, row: row)
      end
      s
    end
    let!(:additional_seat) { create(:seat, sector: sector) }

    before { subject.valid? }

    context 'when selling options are enabled' do
      context "and reservation doesn't meet them" do
        error_messages.each do |key, message|
          it "adds error message for #{key}" do
            expect(subject.errors.full_messages).to include message
          end
        end
      end

      context 'and reservation meets them' do
        let(:sector) { create(:sector) }
        let(:rows) { %w[A A] }
        let(:additional_seat) {}

        error_messages.each do |key, message|
          it "does not add error message for #{key}" do
            expect(subject.errors.full_messages).not_to include message
          end
        end
      end
    end

    context 'when selling options are disabled' do
      let(:sector) { create(:sector) }

      error_messages.each do |key, message|
        it "does not add error message for #{key}" do
          expect(subject.errors.full_messages).not_to include message
        end
      end
    end
  end
end
