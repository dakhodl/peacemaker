class PeaceNet
  def self.get(peer_host, path)
    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      uri = URI("http://#{peer_host}#{path}")
      req = Net::HTTP::Get.new(uri)
      
      Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
    else
      Tor::HTTP.get(peer_host, path)
    end
  end

  def self.post(peer_host, path, body_params = "")
    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      uri = URI("http://#{peer_host}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(
        uri.request_uri,
        'Content-type': 'application/json'
      )
      request.body = body_params
      http.request(request)
    else
      Tor::HTTP.post(peer_host, body_params, path)
    end
  end
end