class AddShiftInventoryUpdateRefToDeliveries < ActiveRecord::Migration[5.0]
  def change
    add_reference :deliveries, :shift_inventory_update, index: true, foreign_key: true
  end
end
