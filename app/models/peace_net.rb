class PeaceNet
  def self.get(peer_host, path)
    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      Net::HTTP.get(peer_host, path)
    else
      Tor::HTTP.get(peer_host, path)
    end
  end

  def self.post(peer_host, path, body_params = {})
    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      Net::HTTP.post(URI("http://#{peer_host}#{path}"), body_params.to_json)
    else
      Tor::HTTP.post(peer_host, body_params, path)
    end
  end
end