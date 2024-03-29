require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.on :startup do
    Sidekiq::Cron::Job.create(
      name: 'start_auction_job',
      cron: '*/5 * * * *', # Run every 5 minutes
      class: 'StartAuctionJob'
    )

    Sidekiq::Cron::Job.create(
      name: 'end_auction_job',
      cron: '*/5 * * * *', # Run every 5 minutes
      class: 'EndAuctionJob'
    )
  end
end