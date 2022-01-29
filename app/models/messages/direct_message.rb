class Messages::DirectMessage < Message
  validates_presence_of :body

  def self.model_name
    Message.model_name
  end

  def serializable_hash(*args)
    super(
      only: [:created_at, :uuid, :body, :author], 
      methods: [:ad_uuid, :message_thread_uuid]
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

  def upsert_from_peer!(response, peer)
    ad = Ad.find_by(uuid: response['resource']['ad_uuid'])



    message_thread ||= MessageThread.find_or_initialize_by(ad: ad, uuid: response['resource']['message_thread_uuid'])
    message_thread.from_peer = true # suppresses first message body presence validation, because encrypted
    message_thread.peer = peer
    message_thread.claim = :mine # direct messages are always mine
    message_thread.save!

    update!(
      response['resource'].
      merge(message_thread: message_thread).
      except('message_thread_uuid', 'ad_uuid')
    )
  end

  def send_to_peer
    return if ad.self_authored? && lead? # dont send back to peer, they just sent it
    return if !ad.self_authored? && advertiser?

    Webhook::ResourceSendJob.perform_later('Messages::DirectMessage', id, uuid, peer)
  end
end