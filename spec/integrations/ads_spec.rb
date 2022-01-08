require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  # let!(:peer) { create(:peer) }

  scenario 'creating an ad that propagates to a peer' do
    visit "http://peer_1:3000/"
    expect(page).to have_content('Peer 2')
    expect(page).to have_content('peer_2:3000')
    click_on 'Ads'
    expect(page).to have_content('Your ads')
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Message', with: 'Only the best'

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to Ads'

    expect(page).to have_content('Farm fresh eggs')
    sleep 2

    expect_ad_to_have_propagated_to_all_peers("Farm fresh eggs")

    visit_peer(4, 'marketplace')
    # hop distance is shown next to connecting peer.
    # the arrow visual is an svg, harder to test. So the below line reads funny here
    expect(page).to have_content("3 peers\nPeer 3")

    visit_peer(1, 'ads')
    click_on 'Edit'
    fill_in 'Title', with: 'Farm fresh dogs'
    click_on 'Update Ad'
    expect(page).to have_content('Ad was successfully updated.')
    sleep 2

    expect_ad_to_have_propagated_to_all_peers("Farm fresh dogs")

    visit_peer(1, "ads")
    click_on 'Farm fresh dogs'
    click_on 'Delete this ad'
    expect(page).to have_content('Ad was successfully destroyed.')

    # deletes propagate
    expect_ad_to_have_propagated_to_all_peers("Farm fresh dogs", :to_not)
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
