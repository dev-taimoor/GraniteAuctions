class PaymentsController < ApplicationController
  
  def create_checkout_session
    session = Stripe::Checkout::Session.create({
      mode: 'subscription',
      customer: current_user.stripe_account_detail.stripe_customer_id,
      line_items: [{
        quantity: 1,
        price: Rails.application.credentials.stripe_subscription_price_id
      }],
      success_url: ENV['DOMAIN'] + '/subscription?success=true&session_id={CHECKOUT_SESSION_ID}',
      cancel_url: ENV['DOMAIN'] + '/subscription?canceled=true',
    })
    redirect_to session.url, allow_other_host: true
  end

  def subscription
    if params[:success] == 'true'
      session_data = fetch_session_data(params[:session_id])
      update_stripe_details(session_data)
      create_receipt(session_data)
      redirect_to car_collection_path , notice: "Subscription successful"
    else
      redirect_to user_verification_path, notice: 'An Error Occured'
    end
  end

  private

  def fetch_session_data(session_id)
    Stripe::Checkout::Session.retrieve(session_id)
  end

  def update_stripe_details(session_data)
    customer_stripe_account.update(
      subscription_id: session_data.subscription,
      payment_status: session_data.payment_status == "paid" ? true : false,
      expiry_date: Date.today + 1.year
    )
  end

  def create_receipt(session_data)
    receipt = Receipt.new(
      user_id: current_user.id,
      invoice_id: session_data.invoice,
      amount: session_data.amount_total
    )
    receipt.save!
  end

  def customer_stripe_account
    @customer_stripe_account ||= current_user.stripe_account_detail
  end
end
