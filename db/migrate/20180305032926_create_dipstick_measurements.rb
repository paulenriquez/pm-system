class CreateDipstickMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :dipstick_measurements do |t|
      t.decimal :converted_vol
      
      t.timestamps
    end
  end
end
