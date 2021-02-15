# frozen_string_literal: true

class CreateSectors < ActiveRecord::Migration[6.1]
  def change
    create_table :sectors do |t|
      t.string :name
      t.boolean :selling_option_even, default: false
      t.boolean :selling_option_all_together, default: false
      t.boolean :selling_option_avoid_one, default: false
      t.references :event

      t.timestamps
    end
  end
end
