require 'rails_helper'

describe 'Webhooks', type: :request do
  let!(:peer) { create(:peer) }

  describe 'POST /api/v1/webhooks', :perform_jobs do
    let!(:peer_2) { create(:peer) }
    let(:peer_token_stub) { 'e02565fe37d4df45a6331ede6cea17adc4fb78383e093e17' }
    let(:peer_2_token_stub) { 'new-token-per-peer' }
    let(:uuid) { SecureRandom.uuid }

    it 'creates a webhook entry for peer to go fetch resource with token' do
      # simulate receipt of webhook
      expect do
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: peer_token_stub,
          uuid: uuid,
          resource_type: 'Ad',
        }
      end.to change { peer.webhook_receipts.count }.by(1)
      expect(response).to be_successful

      # Incoming ad writes new ad record to db
      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://#{peer.onion_address}/api/v1/webhook/#{uuid}/#{peer_token_stub}.json")
        .with(headers: { 'X-Peacemaker-From' => configatron.my_onion })
        .to_return(status: 200, body: {
          uuid: uuid,
          action: 'upsert',
          resource_type: 'Ad',
          resource: {
            title: 'Incoming ad from Peer 1',
            description: 'cool desc',
            uuid: uuid,
            hops: 3
          }
        }.to_json, headers: {})

      # and ad from peer 1 propagates to peer 2
      n_hop_propagation = stub_request(:post, "http://#{peer_2.onion_address}/api/v1/webhook.json")
                          .with(
                            body: {
                              'from' => configatron.my_onion,
                              'token' => a_kind_of(String),
                              'uuid' => uuid,
                              'resource_type': 'Ad',
                            },
                            headers: { 'X-Peacemaker-From' => configatron.my_onion }
                          )
                          .to_return(status: 200, body: '', headers: {})

      # once to fetch the ad resource
      expect do
        perform_enqueued_jobs
      end.to change { Ad.count }.by(1)
      expect(Ad.last.title).to eql('Incoming ad from Peer 1')

      perform_enqueued_jobs # again to propagate to peer 2
      expect(n_hop_propagation).to have_been_requested.once
    end

    it 'logs webhook entry for a peer deletion, deletes the record, and propagates to other peers' do
      stub_onion_peer_propagation
      ad = create(:ad, peer: peer, uuid: uuid)

      # simulate receipt of webhook
      expect do
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: peer_token_stub,
          uuid: uuid,
          resource_type: 'Ad',
        }
      end.to change { peer.webhook_receipts.count }.by(1)
      expect(response).to be_successful

      # Incoming ad writes new ad record to db
      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://#{peer.onion_address}/api/v1/webhook/#{uuid}/#{peer_token_stub}.json")
        .with(headers: { 'X-Peacemaker-From' => configatron.my_onion })
        .to_return(status: 200, body: {
          action: 'delete',
          uuid: uuid,
          resource_type: 'Ad'
        }.to_json, headers: {})

      # and ad delete from peer 1 propagates to peer 2
      n_hop_propagation = stub_request(:post, "http://#{peer_2.onion_address}/api/v1/webhook.json")
                          .with(
                            body: {
                              from: configatron.my_onion,
                              token: a_kind_of(String),
                              resource_type: 'Ad',
                              uuid: uuid # uuid passes through network
                            },
                            headers: { 'X-Peacemaker-From' => configatron.my_onion }
                          )
                          .to_return(status: 200, body: '', headers: {})

      # once to fetch the ad resource
      expect do
        perform_enqueued_jobs
      end.to change { Ad.count }.by(-1)

      expect do
        perform_enqueued_jobs # again to propagate to peer 2
      end.to change { Webhook::Send.count }.by(1)

      expect(n_hop_propagation).to have_been_requested.twice # once for the stubby create, once for the delete
    end

    it 'logs webhook for peer update, updates the record, and propagates to other peers' do
      stub_onion_peer_propagation
      ad = create(:ad, peer: peer, uuid: uuid)

      # simulate receipt of webhook
      expect do
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: peer_token_stub,
          uuid: uuid,
          resource_type: 'Ad',
        }
      end.to change { peer.webhook_receipts.count }.by(1)
      expect(response).to be_successful

      # Incoming ad writes new ad record to db
      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://#{peer.onion_address}/api/v1/webhook/#{uuid}/#{peer_token_stub}.json")
        .with(headers: { 'X-Peacemaker-From' => configatron.my_onion })
        .to_return(status: 200, body: {
          action: 'upsert',
          uuid: uuid,
          resource_type: 'Ad',
          resource: {
            description: 'This is an updated description',
            hops: 4,
          }
        }.to_json, headers: {})

      # and ad upsert from peer 1 propagates to peer 2
      n_hop_propagation = stub_request(:post, "http://#{peer_2.onion_address}/api/v1/webhook.json")
                          .with(
                            body: {
                              from: configatron.my_onion,
                              token: a_kind_of(String),
                              resource_type: 'Ad',
                              uuid: uuid # uuid passes through network
                            },
                            headers: { 'X-Peacemaker-From' => configatron.my_onion }
                          )
                          .to_return(status: 200, body: '', headers: {})

      # once to fetch the ad resource
      expect do
        perform_enqueued_jobs
      end.to change { ad.reload.description }.from(ad.description).to('This is an updated description')

      expect do
        perform_enqueued_jobs # again to propagate to peer 2
      end.to change { Webhook::Send.count }.by(1)

      expect(n_hop_propagation).to have_been_requested.twice # once for the stubby create, once for the upsert
    end

    it 'only allows updates from original peer in case of mesh' do
      stub_onion_peer_propagation
      ad = create(:ad, peer: peer, uuid: uuid)
      original_ad_count = Ad.count

      # simulate receipt of webhook from peer2
      expect do
        post '/api/v1/webhook.json', params: {
          from: peer_2.onion_address,
          token: peer_token_stub + '-2',
          uuid: uuid,
          resource_type: 'Ad',
        }
      end.to_not change { peer_2.webhook_receipts.count }
      expect(response).to_not be_successful
      expect(response.status).to eql(422)

      expect(Webhook::ResourceFetchJob).to_not have_been_enqueued
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
      get "/api/v1/webhook/#{webhook_send.uuid}/#{webhook_send.token}.json"

      expect(response).to be_successful
      expect(response.parsed_body['resource']).to include(
        'title' => 'Farm fresh eggs',
        'description' => 'What else do you need to know'
      )
    end
  end
end
