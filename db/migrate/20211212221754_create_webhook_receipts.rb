class CreateWebhookReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_receipts do |t|
      t.belongs_to :peer, null: false, foreign_key: true
      t.string :token
      t.references :resource, polymorphic: true
      t.integer :status
      t.string :action

      t.timestamps
    end
  end
end
