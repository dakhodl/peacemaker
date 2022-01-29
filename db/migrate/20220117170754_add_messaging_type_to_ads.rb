class AddMessagingTypeToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :messaging_type, :integer, default: 0, null: false
  end
end
