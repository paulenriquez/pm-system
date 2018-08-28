class AddShiftInventoryUpdateAndTankRefToFuelSales < ActiveRecord::Migration[5.0]
  def change
    add_reference :fuel_sales, :shift_inventory_update, index: true, foreign_key: true
    add_reference :fuel_sales, :tank, index: true, foreign_key: true
  end
end
