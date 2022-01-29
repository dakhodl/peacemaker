class AddUuidToMessageThreads < ActiveRecord::Migration[7.0]
  def change
    add_column :message_threads, :uuid, :string
  end
end
