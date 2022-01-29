class AddOwnerToMessageThreads < ActiveRecord::Migration[7.0]
  def change
    add_column :message_threads, :claim, :integer, default: 0 # defaults to intermediary, bumped after decryption succeeds
    add_index :message_threads, :claim
  end
end
