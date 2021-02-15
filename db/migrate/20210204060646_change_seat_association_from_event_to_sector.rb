# frozen_string_literal: true

class ChangeSeatAssociationFromEventToSector < ActiveRecord::Migration[6.1]
  def change
    remove_column :seats, :event_id, :integer, null: false, foreign_key: true
    add_column :seats, :sector_id, :integer, null: false, foreign_key: true
  end
end
