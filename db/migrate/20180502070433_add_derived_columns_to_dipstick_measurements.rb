class AddDerivedColumnsToDipstickMeasurements < ActiveRecord::Migration[5.0]
  def change
    add_column :dipstick_measurements, :beginning_amt, :decimal
    add_column :dipstick_measurements, :deliveries, :decimal
    add_column :dipstick_measurements, :dispensed, :decimal
    add_column :dipstick_measurements, :ending_amt, :decimal
  end
end
