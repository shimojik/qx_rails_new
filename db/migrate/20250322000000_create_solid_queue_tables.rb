class CreateSolidQueueTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string :concurrency_key
      t.datetime :created_at, null: false

      t.index :scheduled_at
      t.index :finished_at
      t.index [:queue_name, :finished_at]
      t.index [:active_job_id], unique: true, where: "active_job_id IS NOT NULL"
      t.index [:concurrency_key, :finished_at], where: "concurrency_key IS NOT NULL"
    end

    create_table :solid_queue_scheduled_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false

      t.datetime :created_at, null: false

      t.index [:scheduled_at, :priority, :job_id], name: "index_solid_queue_dispatch_all"
      t.index [:queue_name, :scheduled_at, :priority, :job_id], name: "index_solid_queue_dispatch_queue"
    end

    create_table :solid_queue_ready_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false

      t.datetime :created_at, null: false

      t.index [:priority, :job_id], name: "index_solid_queue_poll_all"
      t.index [:queue_name, :priority, :job_id], name: "index_solid_queue_poll_queue"
    end

    create_table :solid_queue_claimed_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
      t.bigint :process_id
      t.datetime :created_at, null: false

      t.index [:process_id]
    end

    create_table :solid_queue_blocked_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string :concurrency_key, null: false
      t.datetime :expires_at, null: false

      t.datetime :created_at, null: false

      t.index [:expires_at, :concurrency_key], name: "index_solid_queue_blocked_executions_for_maintenance"
      t.index [:concurrency_key, :priority, :job_id], name: "index_solid_queue_blocked_executions_for_release"
    end

    create_table :solid_queue_failed_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
      t.text :error
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.datetime :created_at, null: false

      t.index [:queue_name], unique: true
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.bigint :supervisor_id

      t.integer :pid, null: false
      t.string :hostname, null: false
      t.text :metadata

      t.datetime :created_at, null: false

      t.index [:last_heartbeat_at]
      t.index [:supervisor_id]
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:key], unique: true
      t.index [:expires_at]
    end
  end
end
