class AddMoreAttributesToCar < ActiveRecord::Migration[7.0]
  def change
    add_column :cars, :year, :integer, null: false, default: 0
    add_column :cars, :engine_capacity, :integer, null: false, default: 0
    add_column :cars, :kms_driven, :integer, null: false, default: 0
    add_column :cars, :sold, :boolean, default: false, null: false
  end
end
