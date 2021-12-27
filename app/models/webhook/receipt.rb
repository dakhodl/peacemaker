class Webhook::Receipt < ApplicationRecord
  belongs_to :peer
  belongs_to :resource, polymorphic: true, optional: true

  after_commit :fetch_resource, on: :create

  validates_presence_of :peer, :token, :uuid, :resource_type

  validates_inclusion_of :resource_type, in: ['Ad']

  def fetch_resource
    Webhook::ResourceFetchJob.perform_later(self)
  end

  def find_or_initialize_resource
    resource_type.safe_constantize.find_or_initialize_by(uuid: uuid)
  end
end
