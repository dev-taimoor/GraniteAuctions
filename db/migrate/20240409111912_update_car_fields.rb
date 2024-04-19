class UpdateCarFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :cars, :stripe_price_id
    add_column :receipts, :vat_amount, :decimal
    add_column :receipts, :delivery_cost, :integer
  end
end
