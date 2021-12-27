class AddUuidToWebhooks < ActiveRecord::Migration[7.0]
  def change
    add_column :webhook_sends, :uuid, :string
    add_column :webhook_receipts, :uuid, :string
  end
end
