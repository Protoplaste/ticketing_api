class AddUniqunessIndexToTickets < ActiveRecord::Migration[6.1]
  def change
    remove_index :tickets, :seat_id
    add_index :tickets, :seat_id, unique: true
  end
end
