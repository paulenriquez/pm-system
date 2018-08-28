class AddProductRefToTanks < ActiveRecord::Migration[5.0]
  def change
    add_reference :tanks, :product, index: true, foreign_key: true
  end
end
