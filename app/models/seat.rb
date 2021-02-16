# frozen_string_literal: true

class Seat < ApplicationRecord
  belongs_to :sector
  has_one :ticket, dependent: :destroy
  has_one :reservation, through: :ticket
end
