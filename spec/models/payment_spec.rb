# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment) { build(:payment) }

  it { is_expected.to belong_to(:reservation) }

  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:status) }

  it 'set_paid changes status correctly' do
    expect { payment.set_paid }.to change(payment, :status).to 'paid'
  end

  it 'set_refunded changes status correctly' do
    expect { payment.set_refunded }.to change(payment, :status).to 'refunded'
  end

  it 'set_refund failed changes status correctly' do
    expect { payment.set_refund_failed }.to change(payment, :status).to 'refund_failed'
  end
end
