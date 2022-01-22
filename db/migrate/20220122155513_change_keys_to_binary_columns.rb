class ChangeKeysToBinaryColumns < ActiveRecord::Migration[7.0]
  def up
    change_column :ads, :secret_key, :binary
    change_column :ads, :public_key, :binary

    change_column :message_threads, :secret_key, :binary   
    change_column :message_threads, :public_key, :binary

    change_column :messages, :encrypted_body, :binary
  end

  def down

  end
end
