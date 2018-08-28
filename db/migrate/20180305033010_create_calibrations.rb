class CreateCalibrations < ActiveRecord::Migration[5.0]
  def change
    create_table :calibrations do |t|
      t.decimal :amount
      t.text :remarks

      t.timestamps
    end
  end
end
