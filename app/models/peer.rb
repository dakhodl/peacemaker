class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
  has_many :webhook_sends, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, dependent: :destroy, class_name: 'Webhook::Receipt'

  def post_webhook(resource)
    webhook_send = webhook_sends.create!(
      resource: resource,
      action: :created,
      token: SecureRandom.base64
    )

    post_body = {
      from: my_onion,
      token: webhook_send.token
    }.to_json

    send_request(post_body)
  end

  def send_request(body)
    Tor::HTTP.post(onion_address, body, "/api/v1/webhook.json")
  end
end
