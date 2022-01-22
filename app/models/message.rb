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

  before_validation :initialize_peer, if: -> { ad&.direct? }
  before_validation :initialize_thread
  before_validation :encrypt_body, if: -> { ad&.secure? }

  def initialize_peer
    self.peer = Peer.find_or_initialize_by(onion_address: ad.self_authored? ? peer.onion_address : ad.onion_address)
    self.peer.name ||= ordinalized_peer_name
    self.peer.save!
  end

  def initialize_thread
    if ad&.secure?
      self.message_thread ||= MessageThread.find_or_create_by!(ad: ad, peer: peer)
    elsif ad&.direct?
      self.message_thread ||= MessageThread.find_or_create_by!(ad: ad, peer: peer)
    end
  end

  def ordinalized_peer_name
    "#{ad.hops.ordinalize}˚ peer via #{ad.peer_name}"
  end

  def send_to_peer
    if ad&.direct?
      return if from_peer? # dont send back to peer, they just sent it

      Webhook::ResourceSendJob.perform_later('Message', id, uuid, peer)
    elsif ad&.needs_message_propagation?
      # This is confusing as fuck.
      
      Webhook::ResourceSendJob.perform_later('Message', id, uuid, peer === ad.peer ? message_thread.peer : ad.peer)
    end
  end

  def upsert_from_peer!(response, peer)
    update!(response['resource']
      .merge(peer: peer) # set peer so malicious peer cannot masquerade as another
      .merge(author: :from_peer)
      .except('id')) # do not copy primary key from peer
  end

  # uses private key from thread (owner)
  # and public key from ad 
  def encrypt_body
    self.encrypted_body = RbNaCl::SimpleBox
      .from_keypair(ad.public_key, thread.secret_key)
      .encrypt(body)
  end

  delegate :public_key, to: :message_thread

  def as_json
    if ad&.secure?
      # where does my response public key live?
      # feels like it should live on the MessageThread, which is kind of a psuedo object rn.
      # encryp
      super(only: [:created_at, :uuid, :encrypted_body, :public_key])
    elsif ad&.direct?
      super
    else
      super
    end
  end
end
