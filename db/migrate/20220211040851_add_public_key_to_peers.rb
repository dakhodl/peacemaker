class AddPublicKeyToPeers < ActiveRecord::Migration[7.0]
  def change
    add_column :peers, :public_key, :binary
  end
end
