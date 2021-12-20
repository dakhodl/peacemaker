class AddLastOnlineAtToPeers < ActiveRecord::Migration[7.0]
  def change
    add_column :peers, :last_online_at, :timestamp
  end
end
