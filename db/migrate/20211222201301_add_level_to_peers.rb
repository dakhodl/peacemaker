class AddLevelToPeers < ActiveRecord::Migration[7.0]
  def change
    add_column :peers, :trust_level, :integer, default: 0, null: false
  end
end
