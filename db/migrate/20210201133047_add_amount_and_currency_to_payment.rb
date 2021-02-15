# frozen_string_literal: true

class AddAmountAndCurrencyToPayment < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :amount, :integer
    add_column :payments, :currency, :string
    add_column :payments, :status, :integer, default: 0
  end
end
