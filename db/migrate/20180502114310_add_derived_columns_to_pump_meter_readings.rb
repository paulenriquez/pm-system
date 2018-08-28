class AddDerivedColumnsToPumpMeterReadings < ActiveRecord::Migration[5.0]
  def change
    add_column :pump_meter_readings, :beginning_bal, :decimal
    add_column :pump_meter_readings, :calibration, :decimal
    add_column :pump_meter_readings, :dispensed, :decimal
  end
end
