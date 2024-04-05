class CreateReceipt < ActiveRecord::Migration[7.0]
  def change
    create_table :receipts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :invoice_id
      t.integer :amount
      t.integer :car_id
      t.timestamps
    end
  end
end
