class CreateShiftInventoryUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_inventory_updates do |t|
      t.date :date
      t.integer :shift
      t.text :remarks
      
      t.timestamps
    end
  end
end
