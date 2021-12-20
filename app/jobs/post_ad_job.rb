class PostAdJob < ApplicationJob
  queue_as :default

  def perform(ad, peer)
    res = peer.post_webhook(ad)
  rescue SOCKSError::HostUnreachable => e
    # TODO: write offline peer response & retry count
    raise e
  ensure
    AdPeer.create!(peer: peer, ad: ad, status: res&.code || 0)
  end
end
