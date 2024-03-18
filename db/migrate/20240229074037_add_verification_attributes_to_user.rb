class AddVerificationAttributesToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :business_name, :string
    add_column :users, :vat_number, :string
    add_column :users, :breakers_licensing, :string
    add_column :users, :role, :string
  end
end
