class NonFuelSale < ApplicationRecord
    belongs_to :non_fuel, foreign_key: 'product_id'
    belongs_to :shift_inventory_update
end
