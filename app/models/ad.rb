class Ad < ApplicationRecord
  belongs_to :peer, optional: true # set if the ad comes from a peer
  has_many :ad_peers, dependent: :destroy # who has been told about this ad
  has_many :webhook_sends, as: :resource, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, as: :resource, dependent: :destroy, class_name: 'Webhook::Receipt'

  after_commit :propagate_to_peers

  def propagate_to_peers
    Peer.where.not(id: peer_id).find_each do |peer|
      Webhook::ResourceSendJob.perform_later(self, peer)
    end
  end
end
