# app/controllers/concerns/car_payment_concern.rb

module CarPaymentConcern
  extend ActiveSupport::Concern

  def payment_session(car)
    Stripe::Checkout::Session.create({
      mode: 'payment',
      customer: current_user.stripe_account_detail.stripe_customer_id,
      line_items: [{ quantity: 1, price: car.create_stripe_car_price.id }],
      metadata: { car_id: car.id },
      invoice_creation: { enabled: true },
      success_url: ENV['DOMAIN'] + '/car_purchase?success=true&session_id={CHECKOUT_SESSION_ID}',
      cancel_url: ENV['DOMAIN'] + '/car_purchase?success=true',
    })
  end

  def handle_transaction_success
    session_data = fetch_session_data(params[:session_id])
    car = Car.find(session_data.metadata.car_id)
    create_receipt(session_data, car)
    car.update(sold: true)
  end

  private

  def fetch_session_data(session_id)
    Stripe::Checkout::Session.retrieve(session_id)
  end

  def create_receipt(session_data, car)
    debugger
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
