class Peer < ApplicationRecord
  has_many :ads, dependent: :destroy
end
