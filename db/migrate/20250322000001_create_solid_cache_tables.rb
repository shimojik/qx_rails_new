class CreateSolidCacheTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cache_entries do |t|
      t.string :key, null: false
      t.text :value, null: false
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: true

      t.index [:key], unique: true
      t.index [:expires_at]
    end
  end
end
