class Webhook::StatusCheckJob < ApplicationJob
  queue_as :default

  def perform(peer)
    status = peer.get_status
    Rails.logger.info "Peer status: #{status.code} for #{peer.onion_address}"
    peer.update last_online_at: Time.current if status&.code == '200'
  rescue SOCKSError::HostUnreachable => e
  end
end
