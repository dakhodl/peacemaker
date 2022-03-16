class MarketplaceController < ApplicationController
  def index
    @search = Search.new(query: params[:q] || '', hops: params[:hops], trust_channel: params[:trust_channel])
    @ads = @search.ads(page: params[:page] || 1)
  end
end