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
      from_name: from_name_for_resource(webhook_send.resource),
      uuid: uuid,
      resource_type: resource_type,
      api_name_for_resource(resource_type) => webhook_send.resource&.as_json,
      'action_taken': deleted ? 'delete' : 'upsert',
    }.to_json

    PeaceNet.post(peer, api_endpoint_for_resource(resource_type, uuid), post_body)
  end

  def from_name_for_resource(resource)
    ad = resource&.ad
    if resource.is_a?(Message) && ad.present?
      Rails.logger.info "using peer for ad:#{ad.id} = #{ad.peer}"
      "#{ad.hops.ordinalize}˚ peer" # TODO: how is this verified receiver side? 
      # Does it need to be or is that part of the 'direct comms' Ad choice tradeoff? If receiver cares, they should choose Private.
    else
      "Does not matter - this should never be rendered to users"
    end
  end

  def api_endpoint_for_resource(resource_type, uuid)
    endpoint = case resource_type
    when "Messages::DirectMessage", "Messages::AdvertiserMessage", "Messages::LeadMessage"
      "messages"
    when "Ad"
      "ads"
    end

    "/api/v1/#{endpoint}"
  end

  def api_name_for_resource(resource_type)
    case resource_type
    when "Messages::DirectMessage", "Messages::AdvertiserMessage", "Messages::LeadMessage"
      "message"
    when "Ad"
      "ad"
    end
  end
end
