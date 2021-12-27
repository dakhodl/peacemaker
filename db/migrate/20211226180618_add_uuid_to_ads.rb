class AddUuidToAds < ActiveRecord::Migration[7.0]
  def up
    add_column :ads, :uuid, :string

    Ad.find_each do |ad|
      ad.update uuid: SecureRandom.uuid
    end

    add_index :ads, :uuid, unique: true
  end

  def down
    remove_column :ads, :uuid, :string
  end
end
