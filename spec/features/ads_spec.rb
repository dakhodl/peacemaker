require 'rails_helper'

feature 'viewing and managing ads', :js, :perform_jobs do
  scenario 'creating an ad that to a peer' do
    # Capybara.current_driver = :selenium_chrome_headless
    create_peer
    click_on 'Marketplace'
    expect(page).to have_content("Ads")
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Message', with: 'Only the best'

    stub_onion_peer_propagation

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to ads'

    expect(page).to have_content('Farm fresh eggs')
  end

  def create_peer
    # TODO: move to fixture or factory
    visit root_path

    click_on 'New peer'
    fill_in 'Name', with: 'Bob'
    fill_in 'Onion address', with: '123abc.onion'
    click_on 'Create Peer'
    expect(page).to have_content("Peer was successfully created")
  end

  def stub_onion_peer_propagation
    stub_request(:post, "http://123abc.onion/api/v1/webhook.json").
      with(
        headers: { 'X-Peacemaker-From'=> configatron.my_onion }).
      to_return(status: 200, body: "", headers: {})
  end
end