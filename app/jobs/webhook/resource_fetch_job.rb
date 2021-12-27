class Webhook::ResourceFetchJob < ApplicationJob
  queue_as :default

  def perform(webhook_receipt)
    peer = webhook_receipt.peer
    res = Tor::HTTP.get(peer.onion_address, "/api/v1/webhook/#{webhook_receipt.uuid}/#{webhook_receipt.token}.json")
    response = JSON.parse(res.body)
    if response['action'] == 'upsert'
      resource = resource_type(response)
                 .find_or_initialize_by(peer: peer, uuid: response['uuid'])

      resource.update!(response['resource']
        .merge(peer: webhook_receipt.peer) # set peer so malicious peer cannot masquerade as another
        .except('id')) # do not copy pkey from peer
      webhook_receipt.update resource: resource
    else
      resource_type(response)
        .find_by(uuid: response['uuid'])
        .destroy
    end
  end

  def resource_type(response)
    # Do not safe_constantize for fear of code execution, no trust client
    case response['resource_type']
    when 'Ad'
      Ad
    else
      raise 'Unknown resource_type'
    end
  end
end
