class AddPeerToAds < ActiveRecord::Migration[6.1]
  def change
    add_reference :ads, :peer, null: true, foreign_key: true
  end
end
