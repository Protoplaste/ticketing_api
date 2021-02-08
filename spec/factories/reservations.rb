FactoryBot.define do
  factory :reservation do
    status { "unpaid" }
    factory :full_reservation do
      before :create do |reservation|
        sector = create(:sector)
        seats = create_list(:seat, 3, sector: sector)
        seats.each do |seat|
          reservation.tickets << Ticket.new(seat: seat)
        end
      end

      after :create do |reservation|
        create(:payment, reservation: reservation, amount: reservation.total_cost)
      end
    end
  end
end