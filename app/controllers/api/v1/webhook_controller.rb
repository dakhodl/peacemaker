class Api::V1::WebhookController < Api::V1::BaseController
  # POST /api/v1/webhook
  # Used to tell peer of new message with token, to be retreived from sender in second request
  #   until re-using the tor private key to sign requests eliminates this second hop.
  #   see https://github.com/dakhodl/peacemaker/issues/1
  def create
    peer = Peer.find_by(onion_address: params[:from])

    receipt = peer.webhook_receipts.build(token: params[:token])

    if receipt.save
      head :ok
    else
      render json: receipt.errors, status: :unprocessable_entity
    end
  end

  def show
    # find_by 404s for mismatch.
    # if GUUIDs are used, need to find by GUUID in one query, then validate token on separate line
    # to prevent timing attacks
    webhook_send = Webhook::Send.find_by(token: params[:token])

    render json: webhook_send.as_json(include: [:resource])
  end
end
