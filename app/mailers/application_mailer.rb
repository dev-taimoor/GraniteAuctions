class ApplicationMailer < ActionMailer::Base
  include Devise::Mailers

  default from: "graniteauction@gmail.com"
  layout "mailer"
end
