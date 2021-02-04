FactoryBot.define do
  factory :reservation do
    status { "unpaid" }
    factory :full_reservation do
      after :create do |reservation|
        seats = create_list(:seat, 3, event: create(:event))
        seats.each do |seat|
          create(:ticket, seat: seat, reservation: reservation)
        end
        create(:payment, reservation: reservation, amount: reservation.total_cost)
      end
    end
  end
end