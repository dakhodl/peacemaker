class AddUuidToMessages < ActiveRecord::Migration[7.0]
  def up
    add_column :messages, :uuid, :string

    Message.find_each do |message|
      message.update uuid: SecureRandom.uuid
    end

    add_index :messages, :uuid, unique: true
  end

  def down
    remove_column :messages, :uuid, :string
  end
end
