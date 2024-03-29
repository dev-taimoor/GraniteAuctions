class CreateAuctions < ActiveRecord::Migration[7.0]
  def change
    create_table :auctions do |t|
      t.string :title, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :lot_no, null: false
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
