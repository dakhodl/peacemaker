class Ad < ApplicationRecord
  include HasUuid

  belongs_to :peer, optional: true # set if the ad comes from a peer
  has_many :messages
  has_many :webhook_sends, as: :resource, class_name: 'Webhook::Send'
  has_many :webhook_receipts, as: :resource, class_name: 'Webhook::Receipt'
  

  enum :messaging_type, {
    direct: 0,
    secure: 1
  }

  after_commit :propagate_to_peers

  delegate :name, to: :peer, prefix: true, allow_nil: true

  def propagate_to_peers
    Peer.where.not(id: peer_id).find_each do |peer|
      Webhook::ResourceSendJob.perform_later(
        self.class.name,
        id,
        uuid,
        peer,
        deleted: transaction_include_any_action?([:destroy])
      )
    end
  end

  def upsert_from_peer!(response, peer)
    update!(response['resource']
      .merge(peer: peer) # set peer so malicious peer cannot masquerade as another
      .merge(hops: response.dig('resource', 'hops') + 1)
      .except('id')) # do not copy pkey from peer
  end

  # ResourceSendJob#from_name_for_resource API
  def ad
    self
  end

  def self_authored?
    peer_id.nil?
  end
end
