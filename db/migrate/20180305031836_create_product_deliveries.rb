class CreateProductDeliveries < ActiveRecord::Migration[5.0]
  def change
    create_table :product_deliveries do |t|
      t.decimal :qty_delivered
      t.timestamps
    end
  end
end
