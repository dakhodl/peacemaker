class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
  has_many :webhook_sends, dependent: :destroy, class_name: 'Webhook::Send'
  has_many :webhook_receipts, dependent: :destroy, class_name: 'Webhook::Receipt'

  after_commit -> { Webhook::StatusCheckJob.perform_later(self) }, on: :create

  def get_status
    PeaceNet.get(onion_address, '/api/v1/status.json')
  end
end
