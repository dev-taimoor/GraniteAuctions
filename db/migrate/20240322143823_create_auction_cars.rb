class CreateAuctionCars < ActiveRecord::Migration[7.0]
  def change
    create_table :auction_cars do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true

      t.timestamps
    end
  end
end
