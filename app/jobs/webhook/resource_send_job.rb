class Webhook::ResourceSendJob < ApplicationJob
  attr_accessor :peer

  def perform(resource, peer)
    self.peer = peer
    webhook_send = peer.webhook_sends.create!(
      resource: resource,
      action: :created,
      token: SecureRandom.hex(24)
    )

    post_body = {
      from: configatron.my_onion,
      token: webhook_send.token
    }.to_json

    send_webhook(post_body)
  end

  def send_webhook(body)
    Tor::HTTP.post(peer.onion_address, body, '/api/v1/webhook.json')
  end
end
