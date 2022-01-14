class AddAuthorToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :author, :integer, default: 0, null: false
  end
end
