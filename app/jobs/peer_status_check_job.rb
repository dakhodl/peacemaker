class PeerStatusCheckJob < ApplicationJob
  queue_as :default

  def perform
    Peer.find_each do |peer|
      Webhook::StatusCheckJob.perform_later(peer)
    end
  end
end
