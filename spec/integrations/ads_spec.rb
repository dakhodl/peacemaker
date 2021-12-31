require 'rails_helper'

feature 'viewing and managing ads', :js, :perform_jobs do
  let!(:peer) { create(:peer) }

  scenario 'creating an ad that propagations to a peer' do
    visit "peacemaker_test_peer_1"
    click_on 'Marketplace'
    expect(page).to have_content('Marketplace')
    click_on 'New ad'

    fill_in 'Title', with: 'Farm fresh eggs'
    fill_in 'Message', with: 'Only the best'

    click_on 'Create Ad'
    expect(page).to have_content('Ad was successfully created.')
    click_on 'Back to ads'

    expect(page).to have_content('Farm fresh eggs')
  end

  scenario 'deleting an ad propagates to peer' do
    ad = create(:ad)

    visit ad_path(ad)
    click_on 'Delete this ad'
    expect(page).to have_content('Ad was successfully destroyed.')
  end
end
