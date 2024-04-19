class AddHoldAmountToBid < ActiveRecord::Migration[7.0]
  def change
    add_column :bids, :hold_payment_intent, :string
    add_column :bids, :active, :boolean
    add_column :users, :payment_method_id, :string
  end
end
