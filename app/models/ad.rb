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

  before_validation :initialize_keys, if: :secure?
  validates :secret_key, :public_key, presence: true, if: :secure?

  before_validation :initialize_onion_address, if: :direct?
  validates :onion_address, presence: true, if: :direct?

  def initialize_keys
    # secret key is set if I own this ad.
    # only public key is set if this came from someone else
    return if secret_key.present? || public_key.present?

    skey = RbNaCl::PrivateKey.generate
    pkey = skey.public_key

    self.secret_key = skey.to_bytes
    self.public_key = pkey.to_bytes
  end

  def initialize_onion_address
    self.onion_address ||= configatron.my_onion
  end

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

  # sanitize json version of secret key globally
  def as_json
    super(except: :secret_key)
  end

  def needs_message_propagation?
    secure? && peer_id.present?
  end
end
