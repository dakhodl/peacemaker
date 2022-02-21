class Webhook::StatusCheckJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # it'll happen again in 5 minutes anyway, best not to build up a ton of redis mem

  def perform(peer)
    status = peer.get_status
    Rails.logger.info "Peer status: #{status.code} for #{peer.onion_address}"
    peer.update last_online_at: Time.current, public_key: status.body if status&.code == '200'
  rescue SOCKSError::HostUnreachable => e
  end
end
