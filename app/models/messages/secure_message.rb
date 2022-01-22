#
# The peer is always a link back and an ad.peer is the link forward.
#   in intermediaries.

# for terminal message endpoints, sender/receiver,
#   peer is ad.peer for ad respondent
#   peer is message_thread.peer for ad creator
#

class Messages::SecureMessage < Message
  before_validation :encrypt_body

  attr_accessor :base64_public_key, :ad_uuid

  before_create :decrypt_body, if: :final_destination?

  def self.model_name
    Message.model_name
  end

  def initialize_peer
    self.peer ||= ad.peer
  end

  # uses private key from thread (owner)
  # and public key from ad 
  def encrypt_body
    self.encrypted_body ||= Base64.encode64(RbNaCl::SimpleBox
      .from_keypair(ad.public_key, message_thread.secret_key)
      .encrypt(body))
  end

  def decrypt_body
    # TODO: When picking this back up. get this keypair right.
    # Still need to hide proxied threads from Messages UI for intermediaries.
    self.body = RbNaCl::SimpleBox
    .from_keypair(message_thread.public_key, ad.secret_key)
    .decrypt(Base64.decode64(encrypted_body))
  end

  delegate :base64_public_key, to: :message_thread

  def serializable_hash(*args)
    # where does my response public key live?
    # feels like it should live on the MessageThread, which is kind of a psuedo object rn.
    # encryp
    super(only: [:created_at, :uuid, :encrypted_body], methods: [:base64_public_key, :ad_uuid])
  end

  def ad_uuid
    ad.uuid
  end

  def upsert_from_peer!(response, peer)
    ad = Ad.find_by(uuid: response['resource']['ad_uuid'])

    message_thread ||= MessageThread.find_or_initialize_by(ad: ad, peer: peer)
    message_thread.public_key ||= Base64.decode64(response['resource']['base64_public_key'])
    message_thread.save!

    update!(response['resource']
      .merge(peer: peer) # set peer so malicious peer cannot masquerade as another
      .merge(ad: ad)
      .merge(message_thread: message_thread)
      .merge(author: peer == ad.peer ? :advertiser : :lead)) # mark which direction this came from
  end

  def send_to_peer
    return if final_destination?

    Webhook::ResourceSendJob.perform_later('Messages::SecureMessage', id, uuid, recipient_peer)
  end

  def recipient_peer
    lead? ? ad.peer : peer
  end

  def final_destination?
    lead? && ad.self_authored?
  end
end