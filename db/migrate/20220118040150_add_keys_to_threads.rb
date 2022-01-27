class AddKeysToThreads < ActiveRecord::Migration[7.0]
  def change
    add_column :message_threads, :secret_key, :text
    add_column :message_threads, :public_key, :text
  end
end
