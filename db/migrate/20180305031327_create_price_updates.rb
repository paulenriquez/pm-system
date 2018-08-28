class CreatePriceUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :price_updates do |t|
      t.text :remarks
      
      t.timestamps
    end
  end
end
