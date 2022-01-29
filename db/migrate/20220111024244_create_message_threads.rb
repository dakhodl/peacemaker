class CreateMessageThreads < ActiveRecord::Migration[7.0]
  def change
    create_table :message_threads do |t|
      t.belongs_to :ad, foreign_key: true
      t.belongs_to :peer, foreign_key: true
      t.timestamps
    end

    add_column :messages, :message_thread_id, :integer, foreign_key: true
  end
end
