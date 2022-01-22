class MessageThread < ApplicationRecord
  belongs_to :ad, optional: true
  belongs_to :peer

  has_many :messages, dependent: :destroy

  before_create :initialize_keys, if: -> { ad&.secure? }

  def initialize_keys
    return if secret_key.present? || public_key.present?

    skey = RbNaCl::PrivateKey.generate
    pkey = skey.public_key

    self.secret_key = skey.to_bytes
    self.public_key = pkey.to_bytes
  end

  def base64_public_key
    return nil if public_key.blank?

    Base64.encode64(public_key)
  end
end
