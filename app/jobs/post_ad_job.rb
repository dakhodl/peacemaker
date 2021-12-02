class PostAdJob < ApplicationJob
  queue_as :default

  def perform(ad)
    post_body = {
      ad: ad.as_json,
      from: my_onion,
      signature: 'TODO'
    }
    Peer.find_each do |peer|
      res = Tor::HTTP.post("http://#{peer.onion}/api/v1/ads.json", post_body, 3000)
      
      AdPeer.create!(peer: peer, ad: ad, status: res.code)
    end
  end

  # this will live somewhere more global soon enough. maybe configatron
  def my_onion
    @my_onion ||= File.read("hidden_service/hostname").to_s.strip
  end
end
