class AddTankRefToPumpNozzles < ActiveRecord::Migration[5.0]
  def change
    add_reference :pump_nozzles, :tank, index: true, foreign_key: true
  end
end
