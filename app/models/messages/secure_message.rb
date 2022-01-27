#
# The peer is always a link to lead and an ad.peer is the link to advertiser
#   in intermediaries.
#
module Messages::SecureMessage
  extend ActiveSupport::Concern

  included do
    validates_presence_of :encrypted_body
    delegate :base64_public_key, to: :message_thread
    after_create :decrypt_body!, if: :final_destination?
  end

  def serializable_hash(*args)
    super(
      only: [:created_at, :uuid, :encrypted_body], 
      methods: [:base64_public_key, :ad_uuid, :message_thread_uuid, :message_thread_hops]
    )
  end

  def ad_uuid
    ad.uuid
  end

  def message_thread_uuid
    message_thread.uuid
  end

  def message_thread_hops
    message_thread.hops
  end

  def send_to_peer
    return if final_destination?

    Webhook::ResourceSendJob.perform_later(type, id, uuid, recipient_peer)
  end

  def recipient_peer
    lead? ? ad.peer : peer
  end
end