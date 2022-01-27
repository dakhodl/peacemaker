class Webhook::ResourceFetchJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_receipt, :resource

  delegate :peer, to: :webhook_receipt

  def perform(webhook_receipt)
    self.webhook_receipt = webhook_receipt
    self.resource = webhook_receipt.find_or_initialize_resource

    return if resource.peer_id.present? && resource.peer != peer # rely on original peer for updates for now
    # TODO: if original peer is offline for X days, take an update from another?
    unless peer.fetching_allowed?(webhook_receipt.resource_type)
      Rails.logger.info "Peer fetching not allowed for #{webhook_receipt.resource_type} - peer trust level: #{peer.trust_level}"
      return
    end

    res = PeaceNet.get(peer.onion_address, "/api/v1/webhook/#{webhook_receipt.uuid}/#{webhook_receipt.token}.json")
    return if res.code != "200"

    response = JSON.parse(res.body)
    if response['action'] == 'upsert'
      upsert!(response)
    else
      destroy!
    end
  end

  def upsert!(response)
    resource.upsert_from_peer!(response, peer)
    webhook_receipt.update resource: resource, action: :upsert
  end

  def destroy!
    resource.destroy if resource.persisted?
    webhook_receipt.update action: :delete
  end
end
