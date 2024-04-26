class ApplicationMailer < ActionMailer::Base
  include Devise::Mailers

  default from: "Granite Auctions <graniteauction@gmail.com>"
  layout "mailer"
end
