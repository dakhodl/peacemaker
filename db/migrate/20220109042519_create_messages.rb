class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.belongs_to :ad, foreign_key: true
      t.belongs_to :peer, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
