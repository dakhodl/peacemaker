class Messages::DirectMessage < Message
  validates_presence_of :body

  def self.model_name
    Message.model_name
  end

  def initialize_peer
    self.peer = Peer.find_or_initialize_by(onion_address: ad.self_authored? ? peer.onion_address : ad.onion_address)
    self.peer.name ||= ordinalized_peer_name
    self.peer.save!
  end


  def upsert_from_peer!(response, peer)
    update!(response['resource']
      .merge(peer: peer) # set peer so malicious peer cannot masquerade as another
      .merge(author: :lead)
      .except('id')) # do not copy primary key from peer
  end

  def send_to_peer
    return if lead? # dont send back to peer, they just sent it

    Webhook::ResourceSendJob.perform_later('Messages::DirectMessage', id, uuid, peer)
  end
end