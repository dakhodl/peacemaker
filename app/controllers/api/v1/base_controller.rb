class Api::V1::BaseController < ActionController::Base
  skip_before_action :verify_authenticity_token

  before_action :verify_signature
  before_action :verify_peer_trust_level
  before_action :verify_peer_ownership

  #
  # Using https://github.com/RubyCrypto/rbnacl/wiki/Digital-Signatures
  #
  def verify_signature
    signature = Base64.strict_decode64(request.headers['HTTP_X_PEACEMAKER_SIGNATURE'])

    verify_key = RbNaCl::VerifyKey.new(peer.public_key)
    message = if request.get?
      request.fullpath
    else
      request.body.read
    end

    raise 400 unless verify_key.verify(signature, Base64.encode64(message))
  end

  def peer
    @peer ||= if params['resource_type'] == 'Messages::DirectMessage' && controller_name == "messages"
      # only messaging can insert a peer.
      # This prevents, for example, a random person hitting /api/v1/ads to snag the data.
      #   thus giving /ads endpoint a sensible authentication scheme
      Peer.find_or_initialize_by(onion_address: request.headers['HTTP_X_PEACEMAKER_FROM']).tap do |peer|
        peer.name ||= params[:from_name]
        # trust initial contact is providing the right key.
        # this could be forged, but what's the gain?
        # we immediate perform a status check fetch in the background that wll overwrite it
        # and responses will go to the .onion they faked, which they presumably have no control of.
        # and if they do, that's a different problem
        peer.public_key ||= Base64.decode64(params[:message][:base64_public_key])
        peer.save!
      end
    else
      Peer.find_by!(onion_address: request.headers['HTTP_X_PEACEMAKER_FROM'])
    end
  end

  def verify_peer_trust_level
    raise 400 if peer.banned?
    return unless params[:resource_type] === 'Ad' # messages follow ad network anyway
    return unless params[:action_taken] === 'upsert' # DELETES fall back to peer ownership check

    trust_channel = params.dig(:ad, :trust_channel)

    unless peer.incoming_ad_trust_channel_allowed?(trust_channel)
      Rails.logger.info "Peer fetching not allowed for #{self.class} - peer trust level: #{peer.trust_level}"
      raise 400
    end
  end

  def verify_peer_ownership
    resource = params[:resource_type].safe_constantize.find_by(uuid: params[:uuid])

    return if resource.blank? # must be new record coming in
    if resource.peer != peer # record is claimed by someone else
      Webhook::Receipt.create!(resource: resource, uuid: params[:uuid], peer: peer, action: params[:action])
      raise 402 # tell them thanks for update but you don't own.
      # owner can resolve later, perhaps
    end
  end
end
