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

ActiveRecord::Schema.define(version: 20_211_220_185_553) do
  create_table 'ad_peers', force: :cascade do |t|
    t.integer 'peer_id', null: false
    t.integer 'ad_id', null: false
    t.integer 'status', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['ad_id'], name: 'index_ad_peers_on_ad_id'
    t.index ['peer_id'], name: 'index_ad_peers_on_peer_id'
  end

  create_table 'ads', force: :cascade do |t|
    t.string 'title'
    t.text 'message'
    t.integer 'hops'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.integer 'peer_id'
    t.index ['peer_id'], name: 'index_ads_on_peer_id'
  end

  create_table 'peers', force: :cascade do |t|
    t.string 'name'
    t.string 'onion_address'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.datetime 'last_online_at'
  end

  create_table 'webhook_receipts', force: :cascade do |t|
    t.integer 'peer_id', null: false
    t.string 'token'
    t.string 'resource_type'
    t.integer 'resource_id'
    t.integer 'status'
    t.string 'action'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['peer_id'], name: 'index_webhook_receipts_on_peer_id'
    t.index %w[resource_type resource_id], name: 'index_webhook_receipts_on_resource'
  end

  create_table 'webhook_sends', force: :cascade do |t|
    t.integer 'peer_id', null: false
    t.string 'token'
    t.string 'action'
    t.string 'resource_type'
    t.integer 'resource_id'
    t.integer 'status'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['peer_id'], name: 'index_webhook_sends_on_peer_id'
    t.index %w[resource_type resource_id], name: 'index_webhook_sends_on_resource'
  end

  add_foreign_key 'ad_peers', 'ads'
  add_foreign_key 'ad_peers', 'peers'
  add_foreign_key 'ads', 'peers'
  add_foreign_key 'webhook_receipts', 'peers'
  add_foreign_key 'webhook_sends', 'peers'
end
