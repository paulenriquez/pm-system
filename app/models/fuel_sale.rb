class FuelSale < ApplicationRecord
    belongs_to :tank
    belongs_to :shift_inventory_update
end
