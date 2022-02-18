class AddFirstSyncedAtToPeers < ActiveRecord::Migration[7.0]
  def change
    add_column :peers, :first_sync_at, :timestamp
  end
end
