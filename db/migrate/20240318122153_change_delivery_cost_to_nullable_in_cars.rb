class ChangeDeliveryCostToNullableInCars < ActiveRecord::Migration[7.0]
  def change
    change_column :cars, :delivery_cost, :integer, null: true
  end
end
