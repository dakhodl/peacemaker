class Webhook::Receipt < ApplicationRecord
  belongs_to :peer
  belongs_to :resource, polymorphic: true, optional: true

  after_commit :fetch_resource, on: :create

  validates_presence_of :peer, :token, :uuid

  def fetch_resource
    Webhook::ResourceFetchJob.perform_later(self)
  end
end
