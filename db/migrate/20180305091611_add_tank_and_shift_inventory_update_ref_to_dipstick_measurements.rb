class AddTankAndShiftInventoryUpdateRefToDipstickMeasurements < ActiveRecord::Migration[5.0]
  def change
    add_reference :dipstick_measurements, :tank, index: true, foreign_key: true
    add_reference :dipstick_measurements, :shift_inventory_update, index: true, foreign_key: true
  end
end
