class CreateTanks < ActiveRecord::Migration[5.0]
  def change
    create_table :tanks do |t|
      t.integer :tank_num
      t.decimal :capacity

      t.timestamps
    end
  end
end