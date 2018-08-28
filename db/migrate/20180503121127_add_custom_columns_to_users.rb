class AddCustomColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
    add_column :users, :name, :string
    add_column :users, :position, :string
    add_column :users, :account_type, :string
  end
end
