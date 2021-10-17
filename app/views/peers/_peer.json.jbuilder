json.extract! peer, :id, :name, :onion_address, :created_at, :updated_at
json.url peer_url(peer, format: :json)
