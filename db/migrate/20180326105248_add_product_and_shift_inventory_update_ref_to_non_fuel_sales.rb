class AddProductAndShiftInventoryUpdateRefToNonFuelSales < ActiveRecord::Migration[5.0]
  def change
    add_reference :non_fuel_sales, :product, index: true, foreign_key: true
    add_reference :non_fuel_sales, :shift_inventory_update, index: true, foreign_key: true
  end
end
