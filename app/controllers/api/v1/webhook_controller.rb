class Api::V1::WebhookController < Api::V1::BaseController
  # POST /api/v1/webhook
  # Used to tell peer of new message with token, to be retreived from sender in second request
  #   until re-using the tor private key to sign requests eliminates this second hop.
  #   see https://github.com/dakhodl/peacemaker/issues/1
  def create
    receipt = peer.webhook_receipts.build(
      uuid: params[:uuid],
      token: params[:token],
      resource_type: params[:resource_type]
    )

    if receipt.save
      head :ok
    else
      Rails.logger.info receipt.errors.to_a
      render json: receipt.errors, status: :unprocessable_entity
    end
  end

  def show
    # find_by 404s for mismatch.
    webhook_send = Webhook::Send.find_by(token: params[:token])

    # compare uuid outside of db query to mitigate timing attacks
    if webhook_send.uuid == params[:uuid]
      render json: webhook_send.as_json(include: [:resource])
    else
      render json: {}, status: :unauthorized
    end
  end
end
