class AddTrustChannelToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :trust_channel, :integer, null: false, default: 1, index: true
  end
end
