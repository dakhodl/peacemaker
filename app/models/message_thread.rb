class MessageThread < ApplicationRecord
  belongs_to :ad, optional: true
  belongs_to :peer

  has_many :messages, dependent: :destroy
end
