# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

fuel_list = [
    {name: 'Diesel', symbols: ['ADO'], ref_color: 'green'},
    {name: 'Turbo Diesel', symbols: ['PTD', 'ADO T'], ref_color: 'blue-grey'},
    {name: 'XCS', symbols: ['XCS'], ref_color: 'orange'},
    {name: 'Blaze 100', symbols: ['BLZ', 'XUB'], ref_color: 'blue'},
    {name: 'Extra Advance', symbols: ['XTR', 'EXT', 'E10'], ref_color: 'red'}
]
fuel_list.each do |fuel|
    Fuel.create(fuel)
end

non_fuel_list = [
    {classification: 'Gasul', name: 'Gasul 11kg'},
    {classification: 'Lubricants', name: 'Lube'},
    {classification: 'Specialties', name: 'Special Oil'}
]
non_fuel_list.each do |non_fuel|
    NonFuel.create(non_fuel)
end

price_update_list = [
    {remarks: 'First price update'}
]
price_update_list.each do |price_update|
    PriceUpdate.create(price_update)
end

product_price_update_list = [
    {price_update_id: 1, product_id: 1, effective_on: Date.today, new_price: 45.91},
    {price_update_id: 1, product_id: 2, effective_on: Date.today, new_price: 50.22},
    {price_update_id: 1, product_id: 3, effective_on: Date.today, new_price: 40.87},
    {price_update_id: 1, product_id: 4, effective_on: Date.today, new_price: 41.55},
    {price_update_id: 1, product_id: 5, effective_on: Date.today, new_price: 43.69},
    {price_update_id: 1, product_id: 6, effective_on: Date.today, new_price: 100},
    {price_update_id: 1, product_id: 7, effective_on: Date.today, new_price: 110},
    {price_update_id: 1, product_id: 8, effective_on: Date.today, new_price: 120}
]
product_price_update_list.each do |product_price_update|
    ProductPriceUpdate.create(product_price_update)
end

tank_list = [
    {tank_num: 1,capacity: 25000, product_id: 1},
    {tank_num: 2,capacity: 25000, product_id: 2},
    {tank_num: 3,capacity: 25000, product_id: 3},
    {tank_num: 4,capacity: 25000, product_id: 3},
    {tank_num: 5,capacity: 25000, product_id: 4},
    {tank_num: 6,capacity: 25000, product_id: 5}
]
tank_list.each do |tank|
    Tank.create(tank)
end

pump_nozzle_list = [
    {pump_island_num: 1, loading_point_num: 1, nozzle_num: 1, tank_id: 2},
    {pump_island_num: 1, loading_point_num: 1, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 1, loading_point_num: 1, nozzle_num: 3, tank_id: 4},
    {pump_island_num: 1, loading_point_num: 2, nozzle_num: 1, tank_id: 1},
    {pump_island_num: 1, loading_point_num: 2, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 1, loading_point_num: 2, nozzle_num: 3, tank_id: 4},
    {pump_island_num: 1, loading_point_num: 3, nozzle_num: 1, tank_id: 4},
    {pump_island_num: 1, loading_point_num: 3, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 1, loading_point_num: 3, nozzle_num: 3, tank_id: 2},
    {pump_island_num: 1, loading_point_num: 4, nozzle_num: 1, tank_id: 5},
    {pump_island_num: 1, loading_point_num: 4, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 1, loading_point_num: 4, nozzle_num: 3, tank_id: 1},
    {pump_island_num: 2, loading_point_num: 5, nozzle_num: 1, tank_id: 2},
    {pump_island_num: 2, loading_point_num: 5, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 2, loading_point_num: 5, nozzle_num: 3, tank_id: 4},
    {pump_island_num: 2, loading_point_num: 6, nozzle_num: 1, tank_id: 1},
    {pump_island_num: 2, loading_point_num: 6, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 2, loading_point_num: 6, nozzle_num: 3, tank_id: 3},
    {pump_island_num: 2, loading_point_num: 7, nozzle_num: 1, tank_id: 4},
    {pump_island_num: 2, loading_point_num: 7, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 2, loading_point_num: 7, nozzle_num: 3, tank_id: 2},
    {pump_island_num: 2, loading_point_num: 8, nozzle_num: 1, tank_id: 3},
    {pump_island_num: 2, loading_point_num: 8, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 2, loading_point_num: 8, nozzle_num: 3, tank_id: 1},
    {pump_island_num: 3, loading_point_num: 9, nozzle_num: 1, tank_id: 2},
    {pump_island_num: 3, loading_point_num: 9, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 3, loading_point_num: 9, nozzle_num: 3, tank_id: 4},
    {pump_island_num: 3, loading_point_num: 10, nozzle_num: 1, tank_id: 1},
    {pump_island_num: 3, loading_point_num: 10, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 3, loading_point_num: 10, nozzle_num: 3, tank_id: 3},
    {pump_island_num: 3, loading_point_num: 11, nozzle_num: 1, tank_id: 4},
    {pump_island_num: 3, loading_point_num: 11, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 3, loading_point_num: 11, nozzle_num: 3, tank_id: 2},
    {pump_island_num: 3, loading_point_num: 12, nozzle_num: 1, tank_id: 3},
    {pump_island_num: 3, loading_point_num: 12, nozzle_num: 2, tank_id: 6},
    {pump_island_num: 3, loading_point_num: 12, nozzle_num: 3, tank_id: 1}
]
pump_nozzle_list.each do |pump_nozzle|
    PumpNozzle.create(pump_nozzle)
end