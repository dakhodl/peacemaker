require 'rails_helper'

describe Ad do
  specify do
    expect(Ad < ApplicationRecord).to eql(true)
  end
end
