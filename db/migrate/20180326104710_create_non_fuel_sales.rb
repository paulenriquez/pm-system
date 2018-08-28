class CreateNonFuelSales < ActiveRecord::Migration[5.0]
  def change
    create_table :non_fuel_sales do |t|
      t.integer :qty_sold

      t.timestamps
    end
  end
end