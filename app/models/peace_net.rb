class PeaceNet
  def self.get(peer, path)
    signature = Base64.strict_encode64(configatron.signing_key.sign(path))

    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      uri = URI("http://#{peer.onion_address}#{path}")
      req = Net::HTTP::Get.new(uri,
        {
          'X-Peacemaker-Signature' => signature,
          'X-Peacemaker-From' => configatron.my_onion
        })
      
      Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
    else
      Tor::HTTP.get(peer.onion_address, path, headers: {
        'X-Peacemaker-Signature': signature,
        'X-Peacemaker-From': configatron.my_onion
      })
    end
  end

  def self.post(peer, path, body_params = "")
    signature = Base64.strict_encode64(configatron.signing_key.sign(body_params))

    if Rails.env.test? && ENV['INTEGRATION_SPECS']
      uri = URI("http://#{peer.onion_address}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-type'] = 'application/json'
      request['X-Peacemaker-Signature'] = signature
      request['X-Peacemaker-From'] = configatron.my_onion
      
      request.body = body_params
      http.request(request)
    else
      Tor::HTTP.post(peer.onion_address, body_params, path, headers: {
        'X-Peacemaker-Signature': signature,
        'X-Peacemaker-From': configatron.my_onion
      })
    end
  end
end