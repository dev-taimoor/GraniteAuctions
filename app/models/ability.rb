# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    cannot :manage, :all

    if user.role == "admin"
      set_admin_abilities(user)
    else 
      set_user_abilities(user)
    end
  end

  private

  def set_admin_abilities(user)
    can :manage, :all
  end

  def set_user_abilities(user)
    can :read, Car
    can :read, Auction
    can :create, Bid
  end

end
