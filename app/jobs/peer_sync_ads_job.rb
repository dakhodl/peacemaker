class PeerSyncAdsJob < ApplicationJob
  queue_as :default

  attr_accessor :peer

  def perform(peer)
    self.peer = peer
    results_remain = true

    page = 1
    while results_remain
      response = PeaceNet.get(self.peer, "/api/v1/ads?page=#{page}")
      if response.code != "200"
        results_remain = false
        raise "Peer not ready to sync - trying again later."
      end
      data = JSON.parse(response.body).with_indifferent_access
      process_page(data)
      results_remain = false if data[:last_page] || data[:total_pages] === 0
      page += 1
    end

    peer.update first_sync_at: Time.current
  end

  def process_page(data)
    ads = {}
    data[:results].each do |ad_params|
      accepted_ad_params = ad_params.slice(
        :title,
        :uuid,
        :description,
        :hops,
        :messaging_type,
        :base64_public_key,
        :onion_address,
        :created_at,
        :updated_at
      )
      ads[accepted_ad_params[:uuid]] = Ad.new(
        accepted_ad_params.merge(hops: accepted_ad_params[:hops] + 1, peer: peer)
      )
    end

    existing_uuids = Ad.where(uuid: ads.keys).pluck(:uuid)
    
    ads.reject { |uuid, ad| existing_uuids.include?(uuid) }.each do |uuid, ad|
      ad.save
    end
  end
end
