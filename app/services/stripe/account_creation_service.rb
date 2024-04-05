# app/services/stripe/account_creation_service.rb

module Stripe
  # Service for creating Stripe Connect Account to handle payments for club owner
  class AccountCreationService
    def initialize(user_id)
      @user = User.find(user_id)
    end

    # Account Creation
    def account_creation
      account = create_customer_account
      create_stripe_account(account.id)
    rescue Exception => e
      raise e
    end

    private

    # create customer account on stripe for everyone 
    def create_customer_account
      Stripe::Customer.create(
        email: @user.email,
        name: @user.full_name,
        metadata: {
          user_id: @user.id,
          role: @user.role
        }
      )
    end

    # update user data in database
    def create_stripe_account(stripe_account_id)
      StripeAccountDetail.create!(stripe_customer_id: stripe_account_id, user_id: @user.id)
    end
  end
end
