class Webhook::Receipt < ApplicationRecord
  belongs_to :peer
  belongs_to :resource, polymorphic: true, optional: true

  after_commit :fetch_resource, on: :create

  validates_presence_of :peer, :token, :uuid, :resource_type

  validates_inclusion_of :resource_type, in: ['Ad', 'Message']
  validates_inclusion_of :action, in: [:upsert, :delete], allow_nil: true

  validate :related_resource_claimed_by_peer

  def fetch_resource
    Webhook::ResourceFetchJob.perform_later(self)
  end

  def find_or_initialize_resource
    resource_type.safe_constantize.find_or_initialize_by(uuid: uuid)
  end

  def related_resource_claimed_by_peer
    resource = find_or_initialize_resource

    return if resource.peer_id.blank?
    return if resource.peer_id == peer_id

    errors.add(:peer, "The resource #{uuid} has already been claimed by another peer.")
  end
end
