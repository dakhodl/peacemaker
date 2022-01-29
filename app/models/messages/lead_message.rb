#
# Contains routing behavior for message going from an ad responder (lead)
#  back to the ad creator (advertiser)
#
class Messages::LeadMessage < Message
  include  Messages::SecureMessage
  before_create -> { self.author = :lead }

  def initialize_peer
    self.peer ||= ad.peer
  end

  def encrypt_body!
    self.encrypted_body ||= Base64.encode64(RbNaCl::SimpleBox
      .from_keypair(ad.public_key, message_thread.secret_key)
      .encrypt(body))
  end

  def decrypt_body!
    update!(
      body: RbNaCl::SimpleBox
        .from_keypair(message_thread.public_key, ad.secret_key)
        .decrypt(Base64.decode64(encrypted_body))
    )
    message_thread.update claim: :mine
  end

  def final_destination?
    lead? && ad.self_authored?
  end

  def upsert_from_peer!(response, peer)
    Rails.logger.info response
    ad = Ad.find_by(uuid: response['resource']['ad_uuid'])

    message_thread ||= MessageThread.find_or_initialize_by(ad: ad, uuid: response['resource']['message_thread_uuid'])
    message_thread.public_key ||= Base64.decode64(response['resource']['base64_public_key'])
    message_thread.from_peer = true # suppresses first message body presence validation, because encrypted
    message_thread.peer = peer
    message_thread.hops ||= ( response['resource']['message_thread_hops'] || 0 ) + 1
    message_thread.save!

    Rails.logger.info 'UPSERTING LEAD MESSAGE'
    update!(
      response['resource']
      .merge(message_thread: message_thread)
      .except('base64_public_key', 'ad_uuid', 'message_thread_uuid', 'message_thread_hops')
    )
    Rails.logger.info final_destination?
    decrypt_body! if final_destination?
  end
end