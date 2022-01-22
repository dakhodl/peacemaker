class Message < ApplicationRecord
  include HasUuid

  enum :author, {
    advertiser: 0,
    lead: 1,
  }

  belongs_to :ad, optional: true
  belongs_to :peer, optional: true
  belongs_to :message_thread, touch: true

  after_commit :send_to_peer, on: :create

  before_validation :initialize_peer
  before_validation :initialize_thread

  def initialize_thread
    self.message_thread ||= MessageThread.find_or_create_by!(ad: ad, peer: peer)
  end
  
  def ordinalized_peer_name
    "#{ad.hops.ordinalize}˚ peer via #{ad.peer_name}"
  end

  def upsert_from_peer!(*args)
    raise 'to be implemented in subclass'
  end
end
