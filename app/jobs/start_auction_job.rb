class StartAuctionJob < ApplicationJob
  def perform
    Auction.pending.each do |auction|
      auction.update(status: "in_progress") if auction.start_time <= Time.zone.now
    end
  end
end