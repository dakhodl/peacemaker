json.extract! message, :id, :ad_id, :peer_id, :body, :created_at, :updated_at
json.url message_url(message, format: :json)
