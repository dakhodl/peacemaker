class Webhook::Receipt < ApplicationRecord
  belongs_to :peer

  after_commit :fetch_resource, on: :create

  def fetch_resource
    Webhook::ResourceFetchJob.perform_later(self)
  end
end
