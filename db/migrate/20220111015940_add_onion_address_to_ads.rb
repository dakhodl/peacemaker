class AddOnionAddressToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :onion_address, :string
  end
end
