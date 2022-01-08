class Ad < ApplicationRecord
  belongs_to :peer, optional: true # set if the ad comes from a peer
  has_many :webhook_sends, as: :resource, class_name: 'Webhook::Send'
  has_many :webhook_receipts, as: :resource, class_name: 'Webhook::Receipt'

  after_initialize :generate_uuid
  after_commit :propagate_to_peers

  validates :uuid, presence: true, uniqueness: true

  delegate :name, to: :peer, prefix: true, allow_nil: true

  def to_param
    uuid
  end

  def generate_uuid
    self[:uuid] ||= SecureRandom.uuid
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
end
