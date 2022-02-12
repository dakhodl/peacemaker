class Api::V1::AdsController < Api::V1::BaseController
  def create
    ad = peer.ads.find_or_initialize_by(uuid: params[:uuid])

    perform = if params[:action_taken] == 'delete' # couldn't get _method delete to route, screw it
      -> { ad.destroy }
    else
      -> { ad.update ad_params.merge(hops: ad_params[:hops] + 1) }
    end
    
    if perform.call
      head :ok
    else
      render json: {
        errors: ad.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def ad_params
    if params[:action_taken] == 'upsert'
      params.require(:ad).permit(
        :title, 
        :description, 
        :hops,
        :messaging_type, 
        :base64_public_key, 
        :onion_address,
        :created_at,
        :updated_at
      )
    else
      params
    end
  end
end
