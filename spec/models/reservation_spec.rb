# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it { is_expected.to have_many(:tickets).dependent(:destroy) }
  it { is_expected.to have_many(:seats).through(:tickets) }
  it { is_expected.to have_one(:payment) }

  it { is_expected.to validate_presence_of(:tickets) }

  context 'selling options validations' do
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
        it 'adds error message when ticket count is not even' do
          expect(subject.errors.full_messages).to include 'Ticket count cannot be an odd number in this sector'
        end

        it 'adds error message when reservation would leave one seat empty' do
          expect(subject.errors.full_messages).to include 'Ticket count cannot leave one seat empty in this sector'
        end

        it 'adds error message when seats are in different rows' do
          expect(subject.errors.full_messages).to include 'Seat placement cannot reserve seats in different rows in this sector'
        end
      end

      context 'and reservation meets them' do
        let(:sector) { create(:sector) }
        let(:rows) { %w[A A] }
        let(:additional_seat) {}

        it 'does not add error message when ticket count is not even' do
          expect(subject.errors.full_messages).not_to include 'Ticket count cannot be an odd number in this sector'
        end

        it 'does not add error message when reservation would leave one seat empty' do
          expect(subject.errors.full_messages).not_to include 'Ticket count cannot leave one seat empty in this sector'
        end

        it 'does not add error message when seats are in different rows' do
          expect(subject.errors.full_messages).not_to include 'Seat placement cannot reserve seats in different rows in this sector'
        end
      end
    end

    context 'when selling options are disabled' do
      let(:sector) { create(:sector) }

      it 'does not validate the seat number is even' do
        expect(subject.errors.full_messages).not_to include 'Ticket count cannot be an odd number in this sector'
      end

      it "does not validate the reservation won't leave one seat empty" do
        expect(subject.errors.full_messages).not_to include 'Ticket count cannot leave one seat empty in this sector'
      end

      it 'does not validate that seats are next to each other' do
        expect(subject.errors.full_messages).not_to include 'Seat placement cannot reserve seats in different rows in this sector'
      end
    end
  end
end
