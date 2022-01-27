class AddHopsToMessageThreads < ActiveRecord::Migration[7.0]
  def change
    add_column :message_threads, :hops, :integer
  end
end
