FactoryBot.define do
  factory :reservation do
    status { "unpaid" }
    factory :reservation_with_tickets do
      before :create do |reservation|
        sector = create(:sector)
        seats = create_list(:seat, 3, sector: sector)
        seats.each do |seat|
          reservation.tickets << Ticket.new(seat: seat)
        end
      end

      factory :full_reservation do
        after :create do |reservation|
          create(:payment, reservation: reservation)
        end
      end
    end
  end
end