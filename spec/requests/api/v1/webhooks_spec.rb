require 'rails_helper'

describe 'Webhooks', type: :request do
  let!(:peer) { create(:peer) }

  describe 'POST /api/v1/webhooks', :perform_jobs do
    let!(:peer_2) { create(:peer) }
    let(:peer_token_stub) { 'e02565fe37d4df45a6331ede6cea17adc4fb78383e093e17' }
    let(:peer_2_token_stub) { 'new-token-per-peer' }

    it 'creates a webhook entry for peer to go fetch resource with token' do
      # simulate receipt of webhook
      expect do
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: peer_token_stub
        }
      end.to change { peer.webhook_receipts.count }.by(1)
      expect(response).to be_successful

      # Incoming ad writes new ad record to db
      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://#{peer.onion_address}/api/v1/webhook/#{peer_token_stub}.json")
        .with(headers: { 'X-Peacemaker-From' => configatron.my_onion })
        .to_return(status: 200, body: {
          resource_type: 'Ad',
          resource: {
            title: 'Incoming ad from Peer 1',
            message: 'cool desc'
          }
        }.to_json, headers: {})

      expect(SecureRandom).to receive(:hex).once.and_return(peer_2_token_stub)

      # and ad from peer 1 propagates to peer 2
      n_hop_propagation = stub_request(:post, "http://#{peer_2.onion_address}/api/v1/webhook.json")
                          .with(
                            body: "{\"from\":\"#{configatron.my_onion}\",\"token\":\"#{peer_2_token_stub}\"}",
                            headers: { 'X-Peacemaker-From' => configatron.my_onion }
                          )
                          .to_return(status: 200, body: '', headers: {})

      # once to fetch the ad resource
      expect do
        perform_enqueued_jobs
      end.to change { Ad.count }.by(1)
      expect(Ad.last.title).to eql('Incoming ad from Peer 1')

      perform_enqueued_jobs # again to propagate to peer 2
      expect(n_hop_propagation).to have_been_requested
    end
  end

  describe 'GET to /api/v1/webhook/:token' do
    let!(:webhook_send) do
      ad = create(:ad)
      stub_request(:post, "http://#{peer.onion_address}/api/v1/webhook.json")
        .with(
          headers: { 'X-Peacemaker-From' => configatron.my_onion }
        )
        .to_return(status: 200, body: '', headers: {})
      perform_enqueued_jobs # ad creation triggers webhook job

      peer.webhook_sends.last
    end

    it 'returns the resource referenced by token' do
      # TODO: Do we need a GUUID system to deduplicate across peers?
      get "/api/v1/webhook/#{webhook_send.token}.json"

      expect(response).to be_successful
      expect(response.parsed_body['resource']).to include(
        'title' => 'Farm fresh eggs',
        'message' => 'What else do you need to know'
      )
    end
  end
end
