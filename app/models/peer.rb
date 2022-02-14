class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
  has_many :webhook_sends, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, dependent: :destroy, class_name: 'Webhook::Receipt'
  has_many :message_threads, dependent: :destroy
  has_many :messages, dependent: :destroy

  after_commit -> { Webhook::StatusCheckJob.perform_later(self) }, on: :create

  enum :trust_level, {
    banned: 0, # ignore completely
    low_trust: 1, # only messaging 
    medium_trust: 2, # receive ads, message
    high_trust: 3, # receive and propagate ads, message
  }

  MESSAGING_TRUST_LEVELS = %w(low_trust medium_trust high_trust)
  AD_RECEIVE_TRUST_LEVELS = %w(medium_trust high_trust)
  AD_PROPAGATE_TRUST_LEVEL = %w(high_trust)

  before_create :set_defaults

  validates_presence_of :onion_address

  scope :with_public_key_resolved, -> { where.not(public_key: nil) }

  def set_defaults
    self.trust_level ||= :low_trust
  end

  def get_status
    PeaceNet.get(self, '/api/v1/status.json')
  end

  def fetching_allowed?(resource_type)
    case resource_type
    when 'Message', 'Messages::DirectMessage', 'Messages::LeadMessage', 'Messages::AdvertiserMessage'
      MESSAGING_TRUST_LEVELS.include?(trust_level)
    when 'Ad'
      AD_RECEIVE_TRUST_LEVELS.include?(trust_level)
    else
      false
    end
  end
end
