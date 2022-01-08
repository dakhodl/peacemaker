class SetDefaultHopsToZero < ActiveRecord::Migration[7.0]
  def change
    execute 'UPDATE ads SET hops = 0'
    change_column :ads, :hops, :integer, default: 0, null: false
  end
end
