require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  scenario 'onboarding new peer syncs ad dataset' do
    add_peer_5_to_peer_2

    # adding peer2 on peer5 pulls in known ads from peer2
    visit "http://peer_5:3000/peers/new"

    fill_in 'Name', with: 'Peer 2'
    fill_in 'Onion address', with: 'peer_2:3000'
    choose 'Low trust'
    click_on 'Create Peer'

    visit "http://peer_5:3000/marketplace"
    sleep 3
    expect(page).to_not have_content('trusty diesel') # first sync does not include high trust ad
    bump_peer_to_high_trust(on: 2, regarding: 5)
    
    visit "http://peer_5:3000/peers"
    bump_peer_to_high_trust(on: 5, regarding: 2) # bumping will trigger resync
    sleep 3
    visit "http://peer_5:3000/marketplace"
    expect(page).to have_content('trusty diesel') # first sync does not include high trust ad
  end

  def add_peer_5_to_peer_2
    visit "http://peer_2:3000/"

    click_on 'New peer'
    fill_in 'Name', with: 'Peer 5'
    fill_in 'Onion address', with: 'peer_5:3000'
    choose 'Low trust'
    click_on 'Create Peer'

    expect(page).to have_content('Peer 5')
    expect(page).to have_content('Low trust')

    # make ad that peer 5 won't see on first sync
    click_on 'Ads'
    click_on 'New ad'

    fill_in 'Title', with: 'trusty diesel'
    fill_in 'Description', with: 'Only the best'
    choose 'High trust'

    click_on 'Create Ad'
  end

  def bump_peer_to_high_trust(on:, regarding:)
    visit "http://peer_#{on}:3000/"
    click_on "Peer #{regarding}"
    click_on 'Edit'
    choose 'High trust'
    click_on 'Update Peer'
    expect(page).to have_content('Online')
    expect(page).to have_content("Peer #{regarding}")
    expect(page).to have_content('High trust')
  end
end