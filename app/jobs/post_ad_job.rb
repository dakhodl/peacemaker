class PostAdJob < ApplicationJob
  queue_as :default

  def perform(ad, peer)
    post_body = {
      ad: ad.as_json,
      from: File.read("hidden_service/hostname").to_s.strip,
      signature: 'TODO'
    }
    res = Tor::HTTP.post(peer.onion_address, post_body.to_json, "/api/v1/ads.json")
  rescue SOCKSError::HostUnreachable => e
    # TODO: write offline peer response
    raise e
  ensure
    AdPeer.create!(peer: peer, ad: ad, status: res.code)
  end
end
