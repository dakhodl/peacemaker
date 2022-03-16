require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  # let!(:peer) { create(:peer) }

  scenario 'creating an ad that propagates to a peer' do
    visit "http://peer_1:3000/"
    expect(page).to have_content('Peer 2')
    click_on 'Ads'
    expect(page).to have_content("You have no ads.\nCreate an ad")
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Description', with: 'Only the best'

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to Ads'

    expect(page).to have_content('Farm fresh eggs')
    sleep 5

    expect_ad_to_have_propagated_to_all_peers("Farm fresh eggs")

    visit_peer(4, 'marketplace')
    # test searching by text and hops
    expect(page).to have_content("3˚ peer via Peer 3")
    fill_in 'Search', with: 'cars'
    click_on 'Search'
    expect(page).to have_content("No ads found")

    fill_in 'Search', with: 'eggs'
    fill_in 'Max˚', with: '2'
    click_on 'Search'
    expect(page).to have_content("No ads found")
    fill_in 'Max˚', with: '3'
    click_on 'Search'
    expect(page).to have_content("Farm fresh eggs\n3˚ peer via Peer 3")

    visit_peer(1, 'ads')
    click_on 'Edit'
    fill_in 'Title', with: 'Farm fresh dogs'
    click_on 'Update Ad'
    expect(page).to have_content('Ad was successfully updated.')
    sleep 5

    expect_ad_to_have_propagated_to_all_peers("Farm fresh dogs")

    visit_peer(1, "ads")
    click_on 'Farm fresh dogs'
    click_on 'Delete this ad'
    expect(page).to have_content('Ad was successfully destroyed.')

    # deletes propagate
    sleep 5
    expect_ad_to_have_propagated_to_all_peers("Farm fresh dogs", :to_not)

    # all prior were low trust ads
    # high trust ads only go over high trust channels
    visit "http://peer_2:3000/"
    expect(page).to have_content('Peer 3')
    click_on 'Ads'
    click_on 'New ad'

    fill_in 'Title', with: 'High trust diesel'
    fill_in 'Description', with: 'Only the best'
    choose 'High trust'

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to Ads'

    sleep 2
    visit_peer(3)
    expect(page).to have_content('High trust diesel')
    # quick test of search facet
    select 'High trust', from: 'trust_channel'
    click_on 'Search'
    expect(page).to have_content('High trust diesel')
    select 'Low trust', from: 'trust_channel'
    click_on 'Search'
    expect(page).to_not have_content('High trust diesel')

    sleep 2
    visit_peer(4)
    expect(page).to_not have_content('High trust diesel')
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
