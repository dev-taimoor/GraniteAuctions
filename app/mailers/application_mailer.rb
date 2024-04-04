class ApplicationMailer < ActionMailer::Base
  include Devise::Mailers

  default from: "from@example.com"
  layout "mailer"
end
