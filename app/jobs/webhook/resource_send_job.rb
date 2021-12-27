class Webhook::ResourceSendJob < ApplicationJob
  attr_accessor :peer

  #
  # resource_id/_type polymorphic fields are passed directly
  # in case this is a delete action, so that
  # GlobalId lookup does not run
  #
  def perform(resource_type, resource_id, uuid, peer, deleted: false)
    self.peer = peer
    webhook_send = peer.webhook_sends.create!(
      resource_type: resource_type,
      resource_id: resource_id,
      uuid: uuid,
      action: deleted ? :delete : :upsert,
      token: SecureRandom.hex(24)
    )

    post_body = {
      resource_type: resource_type,
      from: configatron.my_onion,
      token: webhook_send.token,
      uuid: uuid
      # we make peer fetch to determine action that was taken.
      # to prevent bad peer from spamming deletes
    }.to_json

    send_webhook(post_body)
  end

  def send_webhook(body)
    Tor::HTTP.post(peer.onion_address, body, '/api/v1/webhook.json')
  end
end
