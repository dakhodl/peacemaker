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

ActiveRecord::Schema.define(version: 2022_03_16_122023) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ads", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "hops", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "peer_id"
    t.string "uuid"
    t.string "onion_address"
    t.integer "messaging_type", default: 0, null: false
    t.binary "secret_key"
    t.binary "public_key"
    t.integer "trust_channel", default: 1, null: false
    t.index ["peer_id"], name: "index_ads_on_peer_id"
    t.index ["uuid"], name: "index_ads_on_uuid", unique: true
  end

  create_table "message_threads", force: :cascade do |t|
    t.bigint "ad_id"
    t.bigint "peer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.binary "secret_key"
    t.binary "public_key"
    t.string "uuid"
    t.integer "hops"
    t.integer "claim", default: 0
    t.index ["ad_id"], name: "index_message_threads_on_ad_id"
    t.index ["claim"], name: "index_message_threads_on_claim"
    t.index ["peer_id"], name: "index_message_threads_on_peer_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "ad_id"
    t.bigint "peer_id"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uuid"
    t.integer "author", default: 0, null: false
    t.integer "message_thread_id"
    t.binary "encrypted_body"
    t.string "type"
    t.index ["ad_id"], name: "index_messages_on_ad_id"
    t.index ["peer_id"], name: "index_messages_on_peer_id"
    t.index ["uuid"], name: "index_messages_on_uuid", unique: true
  end

  create_table "peers", force: :cascade do |t|
    t.string "name"
    t.string "onion_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_online_at", precision: 6
    t.integer "trust_level", default: 1
    t.binary "public_key"
    t.datetime "first_sync_at", precision: 6
  end

  create_table "searches", force: :cascade do |t|
    t.text "query"
    t.integer "hops"
    t.integer "messaging_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "trust_channel"
  end

  create_table "webhook_receipts", force: :cascade do |t|
    t.bigint "peer_id", null: false
    t.string "token"
    t.string "resource_type"
    t.bigint "resource_id"
    t.integer "status"
    t.string "action"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uuid"
    t.index ["peer_id"], name: "index_webhook_receipts_on_peer_id"
    t.index ["resource_type", "resource_id"], name: "index_webhook_receipts_on_resource"
  end

  create_table "webhook_sends", force: :cascade do |t|
    t.bigint "peer_id", null: false
    t.string "token"
    t.string "action"
    t.string "resource_type"
    t.bigint "resource_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uuid"
    t.index ["peer_id"], name: "index_webhook_sends_on_peer_id"
    t.index ["resource_type", "resource_id"], name: "index_webhook_sends_on_resource"
  end

  add_foreign_key "ads", "peers"
  add_foreign_key "message_threads", "ads"
  add_foreign_key "message_threads", "peers"
  add_foreign_key "messages", "ads"
  add_foreign_key "messages", "peers"
  add_foreign_key "webhook_receipts", "peers"
  add_foreign_key "webhook_sends", "peers"
end
