require 'rails_helper'

feature 'viewing and managing peers', :js, :perform_jobs do
  scenario 'creating a peer and seeing its network status' do
    visit root_path

    click_on 'New peer'
    fill_in 'Name', with: 'Bob'
    fill_in 'Onion address', with: '123abc.onion'
    stub_peer_status_request(500)
    click_on 'Create Peer'
    expect(page).to have_content('Peer was successfully created')

    click_on 'Peers'

    # at first, we can't reach the status endpoint for some reason.
    expect(connection_status_for('Bob')).to have_content('Unknown')

    stub_peer_status_request(200)
    Webhook::StatusCheckJob.perform_now(Peer.find_by(name: 'Bob')) # cron kicks in
    visit current_path

    # and now we can see connection
    expect(connection_status_for('Bob')).to have_content('Online')
  end

  def stub_peer_status_request(status)
    stub_request(:get, 'http://123abc.onion/api/v1/status.json')
      .with(headers: { 'X-Peacemaker-From' => configatron.my_onion })
      .to_return(status: status, body: '', headers: {})
  end

  def connection_status_for(peer_name)
    find("span[aria-label=\"Connection status for #{peer_name}\"]")
  end
end
