class UpdateCar < ActiveRecord::Migration[7.0]
  def change
    add_column :cars, :stripe_product_id, :string
    add_column :cars, :stripe_price_id, :string
  end
end
