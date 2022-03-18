class Api::V1::AdsController < Api::V1::BaseController
  skip_before_action :verify_peer_ownership, only: [:index]

  def index
    results = Ad.to_sync_to(peer).order(:created_at).page(params[:page]).per(500)
    render json: {
      total_pages: results.total_pages,
      last_page: results.last_page?,
      results: results
    }
  end

  def create
    ad = peer.ads.find_or_initialize_by(uuid: params[:uuid])

    perform = if params[:action_taken] == 'delete' # couldn't get _method delete to route, screw it
      -> { ad.destroy if ad.persisted? } # it may have been deleted by another peer
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
        :uuid,
        :description,
        :hops,
        :messaging_type,
        :trust_channel,
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
