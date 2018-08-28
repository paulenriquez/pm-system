class AddPumpNozzleAndShiftInventoryUpdateRefToPumpMeterReadings < ActiveRecord::Migration[5.0]
  def change
    add_reference :pump_meter_readings, :pump_nozzle, index: true, foreign_key: true
    add_reference :pump_meter_readings, :shift_inventory_update, index: true, foreign_key: true
  end
end
