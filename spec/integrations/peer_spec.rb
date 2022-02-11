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
end