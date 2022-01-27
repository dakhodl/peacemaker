class AddEncryptedBodyToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :encrypted_body, :text
  end
end
