class AddKeysToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :secret_key, :binary
    add_column :ads, :public_key, :binary
  end
end
