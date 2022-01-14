class Message < ApplicationRecord
  include HasUuid

  enum :author, {
    from_self: 0,
    from_peer: 1,
  }

  belongs_to :ad, optional: true
  belongs_to :peer, optional: true
  belongs_to :message_thread, touch: true

  validates_presence_of :body

  after_commit :send_to_peer, on: :create

  before_validation :initialize_peer
  before_validation :initialize_thread

  def initialize_peer
    self.peer = Peer.find_or_initialize_by(onion_address: ad.onion_address)
    self.peer.name ||= ordinalized_peer_name
    self.peer.save
  end

  def initialize_thread
    self.message_thread ||= MessageThread.find_or_create_by!(ad: ad, peer: peer)
  end

  def ordinalized_peer_name
    "#{ad.hops.ordinalize} degree connection through #{ad.peer_name}"
  end

  def send_to_peer
    Webhook::ResourceSendJob.perform_later('Message', id, uuid, peer)
  end

  def upsert_from_peer!(response, peer)
    update!(response['resource']
      .merge(peer: peer) # set peer so malicious peer cannot masquerade as another
      .except('id')) # do not copy pkey from peer
  end
end
