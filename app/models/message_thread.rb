class MessageThread < ApplicationRecord
  include HasUuid

  belongs_to :ad, optional: true
  belongs_to :peer # is always pointing toward lead - null if user is lead, terminal state

  has_many :messages, dependent: :destroy

  delegate :secure?, :direct?, to: :ad

  attr_accessor :body, :from_peer

  validates_presence_of :body, unless: :from_peer

  scope :mine, -> { joins(:ad).merge(Ad.self_authored).or(where.not(secret_key: nil)) }

  def initialize_keys!
    return if secret_key.present? || public_key.present?

    skey = RbNaCl::PrivateKey.generate
    pkey = skey.public_key

    self.secret_key = skey.to_bytes
    self.public_key = pkey.to_bytes
  end

  def base64_public_key
    return nil if public_key.blank?

    Base64.encode64(public_key)
  end

  def initialize_peer!
    self.peer = Peer.find_or_initialize_by(onion_address: ad.self_authored? ? peer.onion_address : ad.onion_address)
    self.peer.name ||= ordinalized_peer_name
    self.peer.save!
  end

  def lead_view?
    secret_key.present?
  end

  def ordinalized_peer_name
    peer_name, distance = if lead_view?
      [ad.peer_name, ad.hops]
    else # advertiser's pov
      [peer.name, hops]
    end

    # is an immediate peer, just show their name
    return peer_name if (hops || ad.hops) == 1

    "#{distance.ordinalize}˚ peer via #{peer.name}"
  end

  def multi_hop?
    hops.blank? || hops > 1
  end
end
