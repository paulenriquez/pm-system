class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :type

      t.string :name
      t.text :description

      t.string :symbols, array: true
      t.string :ref_color

      t.string :classification

      t.timestamps
    end
  end
end