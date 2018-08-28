class CreateProductPriceUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :product_price_updates do |t|
      t.date :effective_on
      t.decimal :new_price
      
      t.timestamps
    end
  end
end
