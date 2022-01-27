#
# The peer is always a link back and an ad.peer is the link forward.
#   in intermediaries.

# for terminal message endpoints, sender/receiver,
#   peer is ad.peer for ad respondent
#   peer is message_thread.peer for ad creator
#

module Messages::SecureMessage
  extend ActiveSupport::Concern

  included do
    validates_presence_of :encrypted_body
    delegate :base64_public_key, to: :message_thread
    after_create :decrypt_body!, if: :final_destination?
  end

  def serializable_hash(*args)
    # where does my response public key live?
    # feels like it should live on the MessageThread, which is kind of a psuedo object rn.
    # encryp
    super(only: [:created_at, :uuid, :encrypted_body], methods: [:base64_public_key, :ad_uuid, :message_thread_uuid])
  end

  def ad_uuid
    ad.uuid
  end

  def message_thread_uuid
    message_thread.uuid
  end

  def send_to_peer
    return if final_destination?

    Webhook::ResourceSendJob.perform_later(type, id, uuid, recipient_peer)
  end

  def recipient_peer
    lead? ? ad.peer : peer
  end
end