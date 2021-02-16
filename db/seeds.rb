# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Event.find_each(&:destroy)
events = FactoryBot.create_list(:event, 2)
events.each do |event|
  sectors = FactoryBot.create_list(:sector, 5, event: event)
  sectors += FactoryBot.create_list(:sector_with_selling_options, 5, event: event)
  sectors.each do |sector|
    FactoryBot.create_list(:seat, 10, sector: sector)
  end
end