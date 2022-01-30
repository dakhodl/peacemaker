class CreateSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :searches do |t|
      t.text :query
      t.integer :hops
      t.integer :messaging_type

      t.timestamps
    end
  end
end
