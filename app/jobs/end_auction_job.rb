class EndAuctionJob < ApplicationJob
  def perform
    Auction.completed_not_updated.each do |auction|
      auction.cars.each do |car|
        if car.bids.present?
          highest_bid = car.bids.maximum(:amount)
          finalize_car_purchase(highest_bid)
        end
      end
      auction.update(status: "completed")
    end
  end

  def finalize_car_purchase(bid)
    user = User.find(bid.user_id)
    payment_intent = charge_higest_bidder(bid, user)
    if payment_intent.status == "succeeded"
      create_receipt(payment_intent, user, bid.car)
      release_hold_amount(bid)
      bid.car.update(sold: true)
    else
      # need update from  Maurice
    end
  end

  def charge_higest_bidder(bid, user)
    Stripe::PaymentIntent.create({
      customer: user.stripe_account_detail.stripe_customer_id,
      payment_method: user.payment_method_id,
      confirm: true,
      amount: calculate_final_price_in_cents(bid.amount, bid.car.delivery_cost).to_i,
      currency: 'gbp',
      payment_method_types: ['card'],
      expand: ['latest_charge'],
      capture_method: 'automatic',
      receipt_email: user.email
    })
  end


  def create_receipt(payment_intent, user, car)
    receipt = Receipt.new(
      user_id: user.id,
      invoice_id: payment_intent.id,
      amount: payment_intent.amount_received/ 100,
      vat_amount: (car.buy_now_price * 0.2),
      delivery_cost: car.delivery_cost,
      car_id: car.id
    )
    receipt.save!
  end

  def release_hold_amount(bid)
    Stripe::PaymentIntent.cancel(bid.hold_payment_intent)
  end


  def calculate_final_price_in_cents(amount, delivery_cost)
    (amount + (0.2 * amount) + delivery_cost) * 100
  end
end
