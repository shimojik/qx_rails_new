class CreateSolidCableTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cable_streams do |t|
      t.string :name, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:name], unique: true
    end

    create_table :solid_cable_subscriptions do |t|
      t.references :stream, null: false, foreign_key: { to_table: :solid_cable_streams, on_delete: :cascade }
      t.string :connection_id, null: false

      t.datetime :created_at, null: false

      t.index [:connection_id, :stream_id], unique: true
      t.index [:connection_id]
    end

    create_table :solid_cable_messages do |t|
      t.references :stream, null: false, foreign_key: { to_table: :solid_cable_streams, on_delete: :cascade }
      t.text :data, null: false
      t.string :broadcastable_type
      t.bigint :broadcastable_id

      t.datetime :created_at, null: false

      t.index [:broadcastable_type, :broadcastable_id], name: "index_solid_cable_messages_on_broadcastable"
    end
  end
end
