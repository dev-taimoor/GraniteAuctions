# frozen_string_literal: true

module Stripe
  # Service for creating Stripe Connect Account to handle payments for club owner
  class AccountSubscriptionService
    def initialize(user_id)
      @user = User.find(user_id)
    end

    def create_checkout_session
      session = Stripe::Checkout::Session.create({
        mode: 'subscription',
        line_items: [{
          quantity: 1,
          price: params[:payment][:priceId]
        }],
        success_url: ENV['DOMAIN'] + '/subscription?success=true&session_id={CHECKOUT_SESSION_ID}',
        cancel_url: ENV['DOMAIN'] + '/subscription?canceled=true',
      })

      redirect_to session.url
    end
  end
end
