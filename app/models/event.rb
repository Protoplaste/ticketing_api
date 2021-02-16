# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :sectors, dependent: :destroy
end
