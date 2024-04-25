# app/controllers/concerns/car_payment_concern.rb

module CarPaymentConcern
  extend ActiveSupport::Concern

  def payment_session
    Stripe::Checkout::Session.create({
      mode: 'payment',
      customer: current_user.stripe_account_detail.stripe_customer_id,
      line_items: [{ quantity: 1, price: @car.create_stripe_car_price.id }],
      metadata: { car_id: @car.id },
      invoice_creation: { enabled: true },
      success_url: Rails.application.credentials.domain + '/car_purchase?success=true&session_id={CHECKOUT_SESSION_ID}',
      cancel_url: Rails.application.credentials.domain + '/car_purchase?success=true',
    })
  end

  def handle_transaction_success
    session_data = fetch_session_data(params[:session_id])
    car = Car.find(session_data.metadata.car_id)
    create_receipt(session_data, car)
    car.update(sold: true)
  end

  def bidding_payment_session(bid)
    Stripe::Checkout::Session.create({
      mode: 'setup',
      currency: 'gbp',
      customer: current_user.stripe_account_detail.stripe_customer_id,
      success_url: Rails.application.credentials.domain + '/successful_bid?success=true&session_id={CHECKOUT_SESSION_ID}',
      cancel_url: Rails.application.credentials.domain + '/successful_bid?success=true',
      metadata: {
        bid_id: bid.id
      }
    })
  end

  def hold_bidding_security(payment_method, bid_id)
    payment_intent = Stripe::PaymentIntent.create({
      customer: current_user.stripe_account_detail.stripe_customer_id,
      payment_method: payment_method,
      confirm: true,
      amount: 25000,
      currency: 'gbp',
      payment_method_types: ['card'],
      expand: ['latest_charge'],
      capture_method: 'manual',
    })
    bid = Bid.find(bid_id)
    bid.update(hold_payment_intent: payment_intent.id)
  end

  private

  def fetch_session_data(session_id)
    Stripe::Checkout::Session.retrieve(id: session_id, expand: ['setup_intent'])
  end

  def create_receipt(session_data, car)
    receipt = Receipt.new(
      user_id: current_user.id,
      invoice_id: session_data.invoice,
      amount: session_data.amount_total/ 100,
      vat_amount: (car.buy_now_price * 0.2),
      delivery_cost: car.delivery_cost,
      car_id: car.id
    )
    receipt.save!
  end
end
