class Ticket < ApplicationRecord
  belongs_to :event
  belongs_to :reservation
  belongs_to :seat
end
