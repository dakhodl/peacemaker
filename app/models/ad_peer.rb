class AdPeer < ApplicationRecord
  belongs_to :peer
  belongs_to :ad

  delegate :name, to: :peer, prefix: true
end
