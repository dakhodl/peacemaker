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
      from_name: from_name_for_resource(webhook_send.resource),
      token: webhook_send.token,
      uuid: uuid
      # we make peer fetch to determine action that was taken.
      # to prevent bad peer from spamming deletes
    }.to_json

    PeaceNet.post(peer.onion_address, '/api/v1/webhook.json', post_body)
  end

  def from_name_for_resource(resource)
    ad = resource.ad
    if resource.is_a?(Message) && ad.present? && ad.hops == 2
      "Direct peer of #{ad.peer.onion_address}" # TODo: how is this verified receiver side?
    elsif resource.is_a?(Message) && ad.present?
      "#{ad.hops.ordinalize} degree connection" # TODO: how is this verified receiver side? 
      # Does it need to be or is that part of the 'direct comms' Ad choice tradeoff? If receiver cares, they should choose Private.
    else
      "Does not matter - this should never be rendered to users"
    end
  end
end
