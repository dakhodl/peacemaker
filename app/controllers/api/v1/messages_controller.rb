class Api::V1::MessagesController < Api::V1::BaseController
  PERMITTED_MESSAGE_CLASSES = [
    'Messages::DirectMessage',
    'Messages::LeadMessage',
    'Messages::AdvertiserMessage'
  ]
  def create
    message = message_class.find_or_initialize_by(uuid: params[:uuid])
    
    if message.upsert_from_peer!(message_params, peer)
      head :ok
    else
      render json: {
        errors: message.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(
      # shared attributes
      :created_at,
      :uuid,
      :body,
      :author,
      :ad_uuid,
      # secure message attributes
      :message_thread_uuid,
      :message_thread_hops,
      :base64_public_key,
      :encrypted_body
    )
  end

  def message_class
    raise 404 unless PERMITTED_MESSAGE_CLASSES.include?(params[:resource_type])
    params[:resource_type].safe_constantize
  end
end
