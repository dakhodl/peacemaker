require 'rails_helper'

describe 'Webhooks', type: :request do
  before(:each) { host! '127.0.0.1' }

  describe 'POST /api/v1/webhooks', :perform_jobs do

    it "creates a webhook entry for peer to go fetch resource with token" do
      peer = create(:peer)
      
      ad = create(:ad)
      stub_request(:post, "http://test-1.onion/api/v1/webhook.json").
        with(
          headers: { 'X-Peacemaker-From'=> configatron.my_onion }).
        to_return(status: 200, body: "", headers: {})
      perform_enqueued_jobs # ad creation triggers webhook job

      webhook_send = peer.webhook_sends.last 

      # simulate a re-send of webhook
      expect {
        post '/api/v1/webhook.json', params: {
          from: peer.onion_address,
          token: webhook_send.token
        }
      }.to change { peer.webhook_receipts.count }.by(1)
      

      expect(Webhook::ResourceFetchJob).to have_been_enqueued
      stub_request(:get, "http://test-1.onion/api/v1/webhook/#{webhook_send.token}.json").
         with(headers: { 'X-Peacemaker-From'=> configatron.my_onion }).
         to_return(status: 200, body: webhook_send.to_json(include: [:resource]), headers: {})
      perform_enqueued_jobs
      

      expect(response).to be_successful
    end
  end
end