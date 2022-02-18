require 'integration_helper'

feature 'viewing and managing ads', :js, :perform_jobs, :integration do
  scenario 'creating and editing a peer' do
    visit "http://admin:secret@peer_1:3000/"
    click_on 'New peer'

    fill_in 'Name', with: 'Peer 3'
    fill_in 'Onion address', with: 'peer_3:3000'

    choose 'Medium trust'

    click_on 'Create Peer'

    expect(page).to have_content('Peer 3')
    expect(page).to have_content('Medium trust')

    click_on 'Edit'
    choose 'High trust'
    click_on 'Update Peer'
    expect(page).to have_content('Online')
    expect(page).to have_content('Peer 3')
    expect(page).to have_content('High trust')
  end

  scenario 'onboarding new peer syncs ad dataset' do
    visit "http://admin:secret@peer_2:3000/"

    click_on 'New peer'

    fill_in 'Name', with: 'Peer 5'
    fill_in 'Onion address', with: 'peer_5:3000'

    choose 'High trust'

    click_on 'Create Peer'

    # adding peer2 on peer5 pulls in known ads from peer2
    visit "http://admin:secret@peer_5:3000/"
    click_on 'New peer'

    fill_in 'Name', with: 'Peer 2'
    fill_in 'Onion address', with: 'peer_2:3000'

    choose 'High trust'

    click_on 'Create Peer'

    visit "http://admin:secret@peer_5:3000/marketplace"

    expect(page).to have_content('Farm fresh pogs') # An ad through peer 2 is already appearing
  end
end