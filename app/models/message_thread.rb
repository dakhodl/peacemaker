class MessageThread < ApplicationRecord
  belongs_to :ad, optional: true
  belongs_to :peer

  has_many :messages, dependent: :destroy

  before_create :intialize_keys, if: -> { ad&.secure? }

  def initialize_keys
    return if secret_key.present?

    skey = RbNaCl::PrivateKey.generate
    pkey = skey.public_key

    self.secret_key = skey.to_bytes
    self.public_key = pkey.to_bytes
  end
end
