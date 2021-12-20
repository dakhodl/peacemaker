require 'rails_helper'

describe 'Webhooks', type: :request do
  before(:each) { host! '127.0.0.1' }

  let!(:peer) { create(:peer) }

  let!(:webhook_send) do      
    ad = create(:ad)
    stub_request(:post, "http://#{peer.onion_address}/api/v1/webhook.json").
      with(
        headers: { 'X-Peacemaker-From'=> configatron.my_onion }).
      to_return(status: 200, body: "", headers: {})
    perform_enqueued_jobs # ad creation triggers webhook job

    peer.webhook_sends.last 
  end

  describe 'POST /api/v1/webhooks', :perform_jobs do
    it "creates a webhook entry for peer to go fetch resource with token" do
      # simulate a re-send of webhook
      expect {
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: webhook_send.token
        }
      }.to change { peer.webhook_receipts.count }.by(1)
      

      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://#{peer.onion_address}/api/v1/webhook/#{webhook_send.token}.json").
         with(headers: { 'X-Peacemaker-From'=> configatron.my_onion }).
         to_return(status: 200, body: webhook_send.to_json(include: [:resource]), headers: {})
      perform_enqueued_jobs
      

      expect(response).to be_successful
    end
  end

  describe 'GET to /api/v1/webhook/:token' do
    it "returns the resource referenced by token" do
      # TODO: Do we need a GUUID system to deduplicate across peers?
      get "/api/v1/webhook/#{webhook_send.token}.json"

      expect(response).to be_successful
      expect(response.parsed_body['resource']).to include(
        "title"=>"Farm fresh eggs",
        "message"=>"What else do you need to know",
      )
    end
  end
end