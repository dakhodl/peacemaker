class Ad < ApplicationRecord
  include HasUuid

  paginates_per 10

  belongs_to :peer, optional: true # set if the ad comes from a peer
  has_many :message_threads, dependent: :destroy
  has_many :webhook_sends, as: :resource, class_name: 'Webhook::Send', dependent: :destroy
  has_many :webhook_receipts, as: :resource, class_name: 'Webhook::Receipt', dependent: :destroy

  enum :messaging_type, {
    direct: 0,
    blinded: 1
  }

  after_commit :propagate_to_peers

  delegate :name, to: :peer, prefix: true, allow_nil: true

  before_validation :initialize_keys, if: :blinded?
  validates_presence_of :public_key, if: :blinded?
  validates_presence_of :secret_key, if: -> { blinded? && self_authored? }

  before_validation :initialize_onion_address, if: :direct?
  validates :onion_address, presence: true, if: :direct?

  validates :description, :title, :messaging_type, presence: true

  scope :self_authored, -> { where(peer_id: nil) }
  scope :from_peers, -> { where.not(peer_id: nil) }

  def initialize_keys
    # secret key is set if I own this ad.
    # only public key is set if this came from someone else
    return if secret_key.present? || public_key.present?

    skey = RbNaCl::PrivateKey.generate
    pkey = skey.public_key


    self[:secret_key] = skey.to_bytes
    self[:public_key] = pkey.to_bytes
  end

  def base64_public_key
    return nil if public_key.blank?

    Base64.encode64(public_key)
  end

  def base64_public_key=(key)
    return if key.blank?

    self.public_key = Base64.decode64(key)
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

  # ResourceSendJob#from_name_for_resource API
  def ad
    self
  end

  def self_authored?
    peer_id.nil?
  end

  # sanitize json version of secret key globally
  def serializable_hash(*args)
    if blinded?
      super(except: [:id, :peer_id, :onion_address, :secret_key, :public_key], methods: [:base64_public_key])
    else
      super(except: [:id, :peer_id, :secret_key, :public_key])
    end
  end
end
