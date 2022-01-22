class AddKeysToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :secret_key, :text
    add_column :ads, :public_key, :text
  end
end
