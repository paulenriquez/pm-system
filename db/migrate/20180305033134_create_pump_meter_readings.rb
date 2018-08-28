class CreatePumpMeterReadings < ActiveRecord::Migration[5.0]
  def change
    create_table :pump_meter_readings do |t|
      t.decimal :ending_bal
      
      t.timestamps
    end
  end
end
