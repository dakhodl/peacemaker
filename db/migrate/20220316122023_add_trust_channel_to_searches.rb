class AddTrustChannelToSearches < ActiveRecord::Migration[7.0]
  def change
    add_column :searches, :trust_channel, :integer, index: true
  end
end
