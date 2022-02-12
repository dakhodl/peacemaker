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
    message = if action_name == :show
      request.path
    else
      request.body.read
    end

    raise 400 unless verify_key.verify(signature, message)
  end

  def peer
    @peer ||= if params['resource_type'] == 'Messages::DirectMessage'
      Peer.find_or_initialize_by(onion_address: request.headers['X-Peacemaker-From']).tap do |peer|
        peer.name ||= params[:from_name]
        peer.save!
      end
    else
      Peer.find_by!(onion_address: request.headers['HTTP_X_PEACEMAKER_FROM'])
    end
  end

  def verify_peer_trust_level
    unless peer.fetching_allowed?(params[:resource_type])
      Rails.logger.info "Peer fetching not allowed for #{webhook_receipt.resource_type} - peer trust level: #{peer.trust_level}"
      raise 400
    end
  end

  def verify_peer_ownership
    resource = params[:resource_type].safe_constantize.find_by(uuid: params[:uuid])

    return if resource.blank? # must be new record coming in
    raise 402 if resource.peer != peer # record is claimed by someone else - dispute resolution TBD
  end
end
