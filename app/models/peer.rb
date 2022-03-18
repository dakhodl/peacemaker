class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
  has_many :webhook_sends, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, dependent: :destroy, class_name: 'Webhook::Receipt'
  has_many :message_threads, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum :trust_level, {
    banned: 0, # ignore completely
    low_trust: 1,
    high_trust: 3,
  }

  before_create :set_defaults
  after_commit -> { Webhook::StatusCheckJob.perform_later(self) }, on: :create
  after_commit -> { PeerSyncAdsJob.perform_later(self ) }, on: [:create, :update], if: -> { saved_change_to_attribute?(:trust_level) }

  validates :onion_address, uniqueness: true, presence: true

  scope :with_public_key_resolved, -> { where.not(public_key: nil) }

  def set_defaults
    self.trust_level ||= :low_trust
  end

  def get_status
    PeaceNet.get(self, '/api/v1/status.json')
  end

  def incoming_ad_trust_channel_allowed?(channel)
    channel == 'low_trust' || channel == trust_level
  end
end
