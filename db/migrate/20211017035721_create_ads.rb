class CreateAds < ActiveRecord::Migration[6.1]
  def change
    create_table :ads do |t|
      t.string :title
      t.text :message
      t.integer :hops

      t.timestamps
    end
  end
end
