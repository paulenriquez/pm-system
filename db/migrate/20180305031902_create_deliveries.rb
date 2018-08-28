class CreateDeliveries < ActiveRecord::Migration[5.0]
  def change
    create_table :deliveries do |t|
      t.string :delivery_type
      t.string :sales_order_num
      t.string :received_by
      t.time :time_received
      t.string :invoice_num
      t.decimal :amount

      t.text :remarks
      
      t.timestamps
    end
  end
end
