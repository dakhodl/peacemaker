class Webhook::ResourceFetchJob < ApplicationJob
  queue_as :default

  def perform(webhook_receipt)
    peer = webhook_receipt.peer
    res = Tor::HTTP.get(peer.onion_address, "/api/v1/webhook/#{webhook_receipt.token}.json")
    response = JSON.parse(res.body)
    resource_type(response).create!(
      response['resource']
        .merge(peer: webhook_receipt.peer) # set peer so malicious peer cannot masquerade as another
        .except('id') # do not copy pkey from peer
    )
    webhook_receipt
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
