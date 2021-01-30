class Ticket < ApplicationRecord
  belongs_to :reservation, optional: true
  belongs_to :seat
end
