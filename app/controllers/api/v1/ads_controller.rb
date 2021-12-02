class Api::V1::AdsController < Api::V1::BaseController
  def create
    # TODO: authenticate message signature with peer's pubkey

    peer = Peer.find_by(onion: params[:from])
    ad = peer.ads.build(ad_params)
    if ad.save
      head :ok
    else
      render json: {
        errors: ad.errors
      }, :unprocessable_entity
    end
  end

  private

  def ad_params
    params.require(:ad).permit(:title, :message)
  end
end
