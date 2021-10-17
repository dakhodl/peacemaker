class CreatePeers < ActiveRecord::Migration[6.1]
  def change
    create_table :peers do |t|
      t.string :name
      t.string :onion_address

      t.timestamps
    end
  end
end
