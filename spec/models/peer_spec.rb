require 'rails_helper'

describe Peer do
  it { is_expected.to have_many(:ads).dependent(:destroy) }
  it { is_expected.to have_many(:webhook_sends).dependent(:destroy).class_name("Webhook::Send") }
  it { is_expected.to have_many(:webhook_receipts).dependent(:destroy).class_name("Webhook::Receipt") }

  it { is_expected.to validate_inclusion_of(:trust_level).in_array([0,1,2]) }
end