class AddAddressFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :address, :address_line_1

    add_column :users, :address_line_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postcode, :string
    add_column :users, :country, :string
  end
end
