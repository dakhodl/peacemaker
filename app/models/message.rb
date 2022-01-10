class Message < ApplicationRecord
  belongs_to :ad, optional: true
  belongs_to :peer, optional: true

  validates_presence_of :body
end
