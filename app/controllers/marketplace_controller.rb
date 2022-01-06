class MarketplaceController < ApplicationController
  def index
    @ads = Ad.includes(:peer).where.not(peer: nil)
  end
end