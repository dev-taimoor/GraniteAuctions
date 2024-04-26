class EndAuctionJob < ApplicationJob
  def perform
    Auction.completed_not_updated.each do |auction|
      auction.cars.each do |car|
        if car.bids.present?
          highest_bid = car.bids.order(amount: :desc).first
          finalize_car_purchase(highest_bid)
          update_bids(bids)
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
      payment_intent = Stripe::PaymentIntent.capture(bid.hold_payment_intent)
      create_receipt(payment_intent, user, bid.car, true)
      UserMailer.payment_failed(user).deliver_now
    end
  end

  def update_bids(bids)
    bids.each do |bid|
      release_hold_amount(bid)
      bid.update(active: false)
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

  def create_receipt(payment_intent, user, car, hold_receipt = false)
    receipt_data = {
      user_id: user.id,
      invoice_id: payment_intent.id,
      amount: payment_intent.amount_received/ 100,
      car_id: car.id
    }
    if !hold_receipt
      receipt_data[:vat_amount] = (car.buy_now_price * 0.2)
      receipt_data[:delivery_cost] = car.delivery_cost
    end
    receipt_data 
    receipt = Receipt.new(receipt_data)
    receipt.save!
  end

  def release_hold_amount(bid)
    payment_intent = Stripe::PaymentIntent.retrieve(bid.hold_payment_intent)
    if payment_intent && payment_intent.status != 'canceled'
      Stripe::PaymentIntent.cancel(bid.hold_payment_intent)
    end
  end


  def calculate_final_price_in_cents(amount, delivery_cost)
    (amount + (0.2 * amount) + delivery_cost) * 100
  end
end
