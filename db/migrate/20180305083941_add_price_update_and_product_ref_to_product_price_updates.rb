class AddPriceUpdateAndProductRefToProductPriceUpdates < ActiveRecord::Migration[5.0]
  def change
    add_reference :product_price_updates, :price_update, index: true, foreign_key: true
    add_reference :product_price_updates, :product, index: true, foreign_key: true
  end
end
