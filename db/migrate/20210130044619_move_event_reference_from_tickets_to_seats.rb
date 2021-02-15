# frozen_string_literal: true

class MoveEventReferenceFromTicketsToSeats < ActiveRecord::Migration[6.1]
  def change
    remove_column :tickets, :event_id, :integer, null: false, foreign_key: true
    add_column :seats, :event_id, :integer, null: false, foreign_key: true
  end
end
