class CreateWebhookSends < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_sends do |t|
      t.belongs_to :peer, null: false, foreign_key: true
      t.string :token
      t.string :action
      t.references :resource, polymorphic: true
      t.integer :status

      t.timestamps
    end
  end
end
p