class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
  has_many :webhook_sends, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, dependent: :destroy, class_name: 'Webhook::Receipt'

  after_commit -> { Webhook::StatusCheckJob.perform_later(self) }, on: :create

  def post_webhook(resource)
    webhook_send = webhook_sends.create!(
      resource: resource,
      action: :created,
      token: SecureRandom.hex(24)
    )

    post_body = {
      from: my_onion,
      token: webhook_send.token
    }.to_json

    send_webhook(post_body)
  end

  def send_webhook(body)
    Tor::HTTP.post(onion_address, body, '/api/v1/webhook.json')
  end

  def get_status
    Tor::HTTP.get(onion_address, '/api/v1/status.json')
  end
end
