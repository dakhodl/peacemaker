require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  scenario 'onboarding new peer syncs ad dataset' do
    add_peer_5_to_peer_2

    # adding peer2 on peer5 pulls in known ads from peer2
    visit "http://peer_5:3000/peers/new"

    fill_in 'Name', with: 'Peer 2'
    fill_in 'Onion address', with: 'peer_2:3000'
    choose 'High trust'
    click_on 'Create Peer'

    visit "http://peer_5:3000/marketplace"

    expect(page).to have_content('Farm fresh pogs') # An ad through peer 2 is already appearing
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

    # quick smoke test of edit form
    click_on 'Edit'
    choose 'High trust'
    click_on 'Update Peer'
    expect(page).to have_content('Online')
    expect(page).to have_content('Peer 5')
    expect(page).to have_content('High trust')
  end
end