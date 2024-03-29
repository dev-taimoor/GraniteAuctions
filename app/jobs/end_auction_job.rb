class EndAuctionJob < ApplicationJob
  def perform
    Auction.current.each do |auction|
      auction.update(status: "completed") if auction.end_time <= Time.zone.now
    end
  end
end