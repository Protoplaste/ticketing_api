class CreateSeats < ActiveRecord::Migration[6.1]
  def change
    create_table :seats do |t|
      t.string :sector
      t.string :row
      t.integer :number

      t.timestamps
    end
  end
end
