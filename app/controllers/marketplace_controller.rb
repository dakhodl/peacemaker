class MarketplaceController < ApplicationController
  def index
    @search = Search.new(query: params[:q] || '', hops: params[:hops])
    @ads = @search.ads(page: params[:page] || 1)
  end
end