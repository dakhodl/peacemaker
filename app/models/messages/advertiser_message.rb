#
# Contains routing behavior for message going from an ad creator (advertiser)
#  back to the ad responder (lead)
#
class Messages::AdvertiserMessage < Message
  include  Messages::SecureMessage

  before_create -> { self.author = :advertiser }

  def initialize_peer
    self.peer ||= ad.peer
  end

  def encrypt_body!
    self.encrypted_body ||= Base64.encode64(RbNaCl::SimpleBox
      .from_keypair(message_thread.public_key, ad.secret_key)
      .encrypt(body))
  end

  def decrypt_body!
    update!(body: RbNaCl::SimpleBox
    .from_keypair(ad.public_key, message_thread.secret_key)
    .decrypt(Base64.decode64(encrypted_body)))
  end

  def final_destination?
    advertiser? && message_thread.secret_key.present?
  end

  def upsert_from_peer!(response, peer)
    Rails.logger.info response
    message_thread = MessageThread.find_by!(uuid: response['resource']['message_thread_uuid'])
    update!(
      response['resource']
      .merge(message_thread: message_thread)
      .except('peer_id', 'base64_public_key', 'ad_uuid', 'message_thread_uuid', 'message_thread_hops')
    )
    decrypt_body! if final_destination?
  end
end