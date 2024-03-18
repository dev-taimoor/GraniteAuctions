class CreateCar < ActiveRecord::Migration[7.0]
  def change
    create_table :cars do |t|
      t.string :make_model, null: false
      t.integer :reserve_auction_price, null: false
      t.integer :buy_now_price, null: false
      t.string :description, null: false
      t.string :location, null: false
      t.integer :delivery_cost, null: false

      t.timestamps
    end
  end
end
