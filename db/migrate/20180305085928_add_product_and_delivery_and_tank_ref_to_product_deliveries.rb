class AddProductAndDeliveryAndTankRefToProductDeliveries < ActiveRecord::Migration[5.0]
  def change
    add_reference :product_deliveries, :product, index: true, foreign_key: true
    add_reference :product_deliveries, :delivery, index: true, foreign_key: true
    add_reference :product_deliveries, :tank, index: true, foreign_key: true
  end
end
