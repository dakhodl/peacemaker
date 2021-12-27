class Webhook::Send < ApplicationRecord
  belongs_to :peer
  belongs_to :resource, polymorphic: true, optional: true
end
