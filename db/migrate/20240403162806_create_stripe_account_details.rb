class CreateStripeAccountDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :stripe_account_details do |t|
      t.string :stripe_customer_id
      t.string :subscription_id
      t.boolean :payment_status, default: false
      t.date :expiry_date
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
