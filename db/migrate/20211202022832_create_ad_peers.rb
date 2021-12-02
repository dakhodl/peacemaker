class CreateAdPeers < ActiveRecord::Migration[6.1]
  def change
    create_table :ad_peers do |t|
      t.belongs_to :peer, null: false, foreign_key: true, description: 'The peer being told about this Ad'
      t.belongs_to :ad, null: false, foreign_key: true, description: 'The Ad being propagated out'
      t.integer :status, null: false, description: 'The HTTP status code from peer when handed this Ad'

      t.timestamps
    end
  end
end
