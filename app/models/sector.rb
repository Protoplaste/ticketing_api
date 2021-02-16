# frozen_string_literal: true

class Sector < ApplicationRecord
  belongs_to :event
  has_many :seats, dependent: :destroy
end
