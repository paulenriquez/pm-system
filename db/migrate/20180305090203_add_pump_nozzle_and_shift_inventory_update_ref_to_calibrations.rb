class AddPumpNozzleAndShiftInventoryUpdateRefToCalibrations < ActiveRecord::Migration[5.0]
  def change
    add_reference :calibrations, :pump_nozzle, index: true, foreign_key: true
    add_reference :calibrations, :shift_inventory_update, index: true, foreign_key: true
  end
end