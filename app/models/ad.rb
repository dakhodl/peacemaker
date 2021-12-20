class Ad < ApplicationRecord
  belongs_to :peer, optional: true # set if the ad comes from a peer
  has_many :ad_peers, dependent: :destroy # who has been told about this ad
  has_many :webhook_sends, as: :resource, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, as: :resource, dependent: :destroy, class_name: 'Webhook::Receipt'

  after_commit :propagate_to_peers, on: :create

  def propagate_to_peers
    return if peer_id.present? # only support one-hop propagation for now

    Peer.find_each do |peer|
      PostAdJob.perform_later(self, peer)
    end
  end
end
