# frozen_string_literal: true

class AddCostToSeat < ActiveRecord::Migration[6.1]
  def change
    add_column :seats, :cost, :integer
  end
end
