class RenameAdMessageToDescription < ActiveRecord::Migration[7.0]
  def change
    rename_column :ads, :message, :description
  end
end
