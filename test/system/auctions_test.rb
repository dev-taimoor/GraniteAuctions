require "application_system_test_case"

class AuctionsTest < ApplicationSystemTestCase
  setup do
    @auction = auctions(:one)
  end

  test "visiting the index" do
    visit auctions_url
    assert_selector "h1", text: "Auctions"
  end

  test "should create auction" do
    visit auctions_url
    click_on "New auction"

    click_on "Create Auction"

    assert_text "Auction was successfully created"
    click_on "Back"
  end

  test "should update Auction" do
    visit auction_url(@auction)
    click_on "Edit this auction", match: :first

    click_on "Update Auction"

    assert_text "Auction was successfully updated"
    click_on "Back"
  end

  test "should destroy Auction" do
    visit auction_url(@auction)
    click_on "Destroy this auction", match: :first

    assert_text "Auction was successfully destroyed"
  end
end
