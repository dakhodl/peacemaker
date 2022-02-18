#
# Receipts help track who knows about what
#  it's useful to know how many peers also know about this ad, a trust signal.
# 
class Webhook::Receipt < ApplicationRecord
  belongs_to :peer
  belongs_to :resource, polymorphic: true, optional: true

  validates_presence_of :peer, :resource_type

  validates_inclusion_of :resource_type, in: ['Ad']
end
