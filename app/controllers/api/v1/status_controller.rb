class Api::V1::StatusController < Api::V1::BaseController
  skip_before_action :verify_signature
  skip_before_action :verify_peer_trust_level
  skip_before_action :verify_peer_ownership

  def show
    send_data configatron.signing_key.verify_key.to_s.b
  end
end
