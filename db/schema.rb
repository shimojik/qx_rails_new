# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_12_025061) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "theme_id", null: false
    t.text "prompt"
    t.integer "generation_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "chapter_summary"
    t.text "chapter_summary_with_content"
    t.string "chapter_num_string"
    t.string "page_num"
    t.datetime "deleted_at"
    t.integer "order_num"
    t.string "chapter_name"
    t.integer "section_num"
    t.string "title"
    t.string "image"
    t.text "content"
    t.text "short_content"
    t.text "editors_note"
    t.boolean "draft"
    t.boolean "public"
    t.datetime "released_at"
    t.datetime "delivered_at"
    t.string "profile_image"
    t.bigint "ranking"
    t.bigint "project_id"
    t.string "uid"
    t.boolean "video", default: false
    t.integer "writer_id"
    t.integer "chapter_num"
    t.index ["deleted_at"], name: "index_articles_on_deleted_at"
    t.index ["theme_id"], name: "index_articles_on_theme_id"
  end

  create_table "audio_clips", force: :cascade do |t|
    t.bigint "audio_id", null: false
    t.text "encoded"
    t.text "transcript"
    t.integer "position"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audio_id"], name: "index_audio_clips_on_audio_id"
  end

  create_table "audio_transcripts", force: :cascade do |t|
    t.bigint "audio_id", null: false
    t.text "body"
    t.string "job_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "corrected_body"
    t.index ["audio_id"], name: "index_audio_transcripts_on_audio_id"
  end

  create_table "audios", force: :cascade do |t|
    t.text "original"
    t.text "encoded"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "uid"
    t.string "title"
    t.integer "layout_type", default: 0
    t.integer "position", default: 0
    t.boolean "listed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.text "prompt"
    t.integer "generation_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "heading_num"
    t.text "body"
    t.datetime "deleted_at"
    t.index ["article_id"], name: "index_chapters_on_article_id"
    t.index ["deleted_at"], name: "index_chapters_on_deleted_at"
  end

  create_table "concepts", force: :cascade do |t|
    t.bigint "theme_id", null: false
    t.string "name"
    t.text "copy"
    t.text "body_copy"
    t.text "description"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_concepts_on_deleted_at"
    t.index ["theme_id"], name: "index_concepts_on_theme_id"
  end

  create_table "issue_causes", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.string "name"
    t.string "display_name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_issue_causes_on_deleted_at"
    t.index ["issue_id"], name: "index_issue_causes_on_issue_id"
  end

  create_table "issue_events", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.string "name"
    t.string "display_name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_issue_events_on_deleted_at"
    t.index ["issue_id"], name: "index_issue_events_on_issue_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "concept_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["concept_id"], name: "index_issues_on_concept_id"
    t.index ["deleted_at"], name: "index_issues_on_deleted_at"
  end

  create_table "player_issue_cause_relation_articles", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "player_issue_cause_relation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["article_id"], name: "index_player_issue_cause_relation_articles_on_article_id"
    t.index ["deleted_at"], name: "index_player_issue_cause_relation_articles_on_deleted_at"
    t.index ["player_issue_cause_relation_id"], name: "index_pic_relations_on_article"
  end

  create_table "player_issue_cause_relations", force: :cascade do |t|
    t.bigint "issue_cause_id", null: false
    t.bigint "parent_player_id"
    t.bigint "child_player_id"
    t.string "relation_type"
    t.string "relation_type_group"
    t.string "parent_player_role"
    t.string "child_player_role"
    t.boolean "parent_player_role_public"
    t.boolean "child_player_role_public"
    t.text "parent_player_comment"
    t.text "child_player_comment"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["child_player_id"], name: "index_player_issue_cause_relations_on_child_player_id"
    t.index ["deleted_at"], name: "index_player_issue_cause_relations_on_deleted_at"
    t.index ["issue_cause_id"], name: "index_player_issue_cause_relations_on_issue_cause_id"
    t.index ["parent_player_id"], name: "index_player_issue_cause_relations_on_parent_player_id"
  end

  create_table "player_issue_event_relation_articles", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "player_issue_event_relation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["article_id"], name: "index_player_issue_event_relation_articles_on_article_id"
    t.index ["deleted_at"], name: "index_player_issue_event_relation_articles_on_deleted_at"
    t.index ["player_issue_event_relation_id"], name: "index_pie_relations_on_article"
  end

  create_table "player_issue_event_relations", force: :cascade do |t|
    t.bigint "parent_player_id"
    t.bigint "child_player_id"
    t.string "relation_type"
    t.string "relation_type_group"
    t.string "parent_player_role"
    t.string "child_player_role"
    t.boolean "parent_player_role_public"
    t.boolean "child_player_role_public"
    t.text "parent_player_comment"
    t.text "child_player_comment"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "issue_event_id", null: false
    t.integer "generation_status", default: 0
    t.string "prompt"
    t.datetime "deleted_at"
    t.index ["child_player_id"], name: "index_player_issue_event_relations_on_child_player_id"
    t.index ["deleted_at"], name: "index_player_issue_event_relations_on_deleted_at"
    t.index ["issue_event_id"], name: "index_player_issue_event_relations_on_issue_event_id"
    t.index ["parent_player_id"], name: "index_player_issue_event_relations_on_parent_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "display_name"
    t.string "label"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prompt"
    t.integer "theme_id"
    t.integer "generation_status", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_players_on_deleted_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "article_summary"
    t.text "prompt"
    t.integer "generation_status"
    t.string "title"
    t.string "image"
    t.text "content"
    t.boolean "draft"
    t.datetime "released_at"
    t.datetime "delivered_at"
    t.bigint "category_id"
    t.text "lead"
    t.bigint "project_id"
    t.string "uid"
    t.boolean "video", default: false
    t.bigint "writer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "themes"
  add_foreign_key "audio_clips", "audios"
  add_foreign_key "audio_transcripts", "audios"
  add_foreign_key "chapters", "articles"
  add_foreign_key "concepts", "themes"
  add_foreign_key "issue_causes", "issues"
  add_foreign_key "issue_events", "issues"
  add_foreign_key "issues", "concepts"
  add_foreign_key "player_issue_cause_relation_articles", "articles"
  add_foreign_key "player_issue_cause_relation_articles", "player_issue_cause_relations"
  add_foreign_key "player_issue_cause_relations", "issue_causes"
  add_foreign_key "player_issue_cause_relations", "players", column: "child_player_id"
  add_foreign_key "player_issue_cause_relations", "players", column: "parent_player_id"
  add_foreign_key "player_issue_event_relation_articles", "articles"
  add_foreign_key "player_issue_event_relation_articles", "player_issue_event_relations"
  add_foreign_key "player_issue_event_relations", "issue_events"
  add_foreign_key "player_issue_event_relations", "players", column: "child_player_id"
  add_foreign_key "player_issue_event_relations", "players", column: "parent_player_id"
end
