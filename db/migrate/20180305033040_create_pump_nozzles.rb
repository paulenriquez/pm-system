class CreatePumpNozzles < ActiveRecord::Migration[5.0]
  def change
    create_table :pump_nozzles do |t|
      t.integer :pump_island_num
      t.integer :loading_point_num
      t.integer :nozzle_num

      t.timestamps
    end
  end
end
