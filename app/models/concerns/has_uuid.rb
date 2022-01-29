module HasUuid
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_uuid
    validates :uuid, presence: true, uniqueness: true
  end

  def generate_uuid
    self[:uuid] ||= SecureRandom.uuid
  end

  def to_param
    uuid
  end
end