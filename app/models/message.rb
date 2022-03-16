class Message < ApplicationRecord
  include HasUuid

  enum :author, {
    advertiser: 0,
    lead: 1,
  }

  belongs_to :message_thread, touch: true

  after_commit :send_to_peer, on: :create

  delegate :peer, :ad, to: :message_thread
  delegate :trust_channel, to: :ad

  def upsert_from_peer!(*args)
    raise 'to be implemented in subclass'
  end
end
