class CreateBids < ActiveRecord::Migration[7.0]
  def change
    create_table :bids do |t|
      t.references :user, null: false, foreign_key: true
      t.references :auction, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
