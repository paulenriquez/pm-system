class AddDateAndShiftIndexToShiftInventoryUpdates < ActiveRecord::Migration[5.0]
  def change
    add_index :shift_inventory_updates, :date
    add_index :shift_inventory_updates, :shift
  end
end