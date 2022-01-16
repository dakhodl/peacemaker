require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  # let!(:peer) { create(:peer) }

  scenario 'creating an ad that propagates to a peer' do
    visit "http://peer_1:3000/"
    expect(page).to have_content('Peer 2')
    click_on 'Ads'
    expect(page).to have_content("You have no ads.\nMake one")
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Message', with: 'Only the best'

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to Ads'

    expect(page).to have_content('Farm fresh eggs')
    sleep 2

    visit_peer(4, 'marketplace')
    click_on 'Farm fresh eggs'
    click_on 'Message'

    fill_in 'Body', with: 'Is this still available?'
    click_on 'Send'

    sleep 2

    visit "http://peer_1:3000/"

  end

  def visit_peer(number, path = "marketplace")
    visit "http://peer_#{number}:3000/#{path}"
  end

  def expect_ad_to_have_propagated_to_all_peers(ad_title, expectation = :to)
    [2,3,4].each do |number|
      sleep 2
      visit_peer(number)
      expect(page).send(expectation, have_content(ad_title))
    end
  end
end
