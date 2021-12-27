require 'rails_helper'

feature 'viewing and managing ads', :js, :perform_jobs do
  let!(:peer) { create(:peer) }

  scenario 'creating an ad that propagations to a peer' do
    visit root_path
    click_on 'Marketplace'
    expect(page).to have_content('Marketplace')
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Message', with: 'Only the best'

    stub_onion_peer_propagation

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to ads'

    expect(page).to have_content('Farm fresh eggs')
  end

  scenario 'deleting an ad propagates to peer' do
    peer_propagation = stub_onion_peer_propagation
    ad = create(:ad)

    visit ad_path(ad)
    delete_propagation = stub_onion_peer_propagation(ad: ad)
    click_on 'Delete this ad'
    expect(page).to have_content('Ad was successfully destroyed.')
    expect(peer_propagation).to have_been_requested.twice # once for create, and then delete
  end
end
