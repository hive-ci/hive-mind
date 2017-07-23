# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161213114018) do

  create_table "brands", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "display_name", limit: 255
    t.string   "alternative",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "device_actions", force: :cascade do |t|
    t.integer  "device_id",   limit: 4
    t.string   "action_type", limit: 255
    t.string   "body",        limit: 255
    t.datetime "executed_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "device_actions", ["device_id", "executed_at"], name: "index_device_actions_on_device_id_and_executed_at", using: :btree

  create_table "device_states", force: :cascade do |t|
    t.integer  "device_id",  limit: 4
    t.string   "component",  limit: 255
    t.integer  "state",      limit: 1,   null: false
    t.string   "message",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "device_states", ["device_id"], name: "index_device_states_on_device_id", using: :btree

  create_table "device_statistics", force: :cascade do |t|
    t.integer  "device_id",  limit: 4
    t.datetime "timestamp"
    t.string   "label",      limit: 255
    t.decimal  "value",                  precision: 16, scale: 8
    t.string   "format",     limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "unit",       limit: 255
  end

  add_index "device_statistics", ["device_id", "label", "timestamp"], name: "index_device_statistics_on_device_id_and_label_and_timestamp", using: :btree

  create_table "device_types", force: :cascade do |t|
    t.string   "classification", limit: 255
    t.text     "description",    limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "serial",      limit: 255
    t.string   "asset_id",    limit: 255
    t.string   "alternative", limit: 255
    t.integer  "model_id",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "plugin_id",   limit: 4
    t.string   "plugin_type", limit: 255
  end

  add_index "devices", ["model_id"], name: "index_devices_on_model_id", using: :btree

  create_table "devices_groups", force: :cascade do |t|
    t.integer "device_id", limit: 4
    t.integer "group_id",  limit: 4
  end

  create_table "devices_hive_queues", id: false, force: :cascade do |t|
    t.integer "device_id",     limit: 4
    t.integer "hive_queue_id", limit: 4
  end

  add_index "devices_hive_queues", ["device_id"], name: "index_devices_hive_queues_on_device_id", using: :btree
  add_index "devices_hive_queues", ["hive_queue_id"], name: "index_devices_hive_queues_on_hive_queue_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "value",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "heartbeats", force: :cascade do |t|
    t.integer  "device_id",           limit: 4
    t.integer  "reporting_device_id", limit: 4
    t.datetime "created_at"
  end

  add_index "heartbeats", ["device_id"], name: "index_heartbeats_on_device_id", using: :btree

  create_table "hive_mind_generic_characteristics", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "value",      limit: 255
    t.integer  "plugin_id",  limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hive_mind_generic_plugins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hive_mind_hive_plugins", force: :cascade do |t|
    t.string   "hostname",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hive_mind_hive_runner_plugin_version_histories", force: :cascade do |t|
    t.integer  "plugin_id",                limit: 4
    t.integer  "runner_plugin_version_id", limit: 4
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "hive_mind_hive_runner_plugin_versions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "version",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hive_mind_hive_runner_version_histories", force: :cascade do |t|
    t.integer  "plugin_id",         limit: 4
    t.integer  "runner_version_id", limit: 4
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "hive_mind_hive_runner_versions", force: :cascade do |t|
    t.string   "version",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hive_mind_mobile_plugins", force: :cascade do |t|
    t.integer  "device_id",               limit: 4
    t.string   "imei",                    limit: 255
    t.string   "serial",                  limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "screenshot_file_name",    limit: 255
    t.string   "screenshot_content_type", limit: 255
    t.integer  "screenshot_file_size",    limit: 4
    t.datetime "screenshot_updated_at"
  end

  create_table "hive_queues", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "ips", force: :cascade do |t|
    t.integer  "device_id",  limit: 4
    t.string   "ip",         limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ips", ["device_id"], name: "index_ips_on_device_id", using: :btree

  create_table "macs", force: :cascade do |t|
    t.integer  "device_id",  limit: 4
    t.string   "mac",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "macs", ["device_id"], name: "index_macs_on_device_id", using: :btree

  create_table "models", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "display_name",   limit: 255
    t.string   "alternative",    limit: 255
    t.integer  "brand_id",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "device_type_id", limit: 4
    t.text     "description",    limit: 65535
    t.string   "img_url",        limit: 255
  end

  add_index "models", ["brand_id"], name: "index_models_on_brand_id", using: :btree
  add_index "models", ["device_type_id"], name: "index_models_on_device_type_id", using: :btree

  create_table "operating_system_histories", force: :cascade do |t|
    t.integer  "device_id",           limit: 4
    t.integer  "operating_system_id", limit: 4
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "operating_system_histories", ["device_id"], name: "index_operating_system_histories_on_device_id", using: :btree

  create_table "operating_systems", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "version",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "primary_id",   limit: 4
    t.integer  "secondary_id", limit: 4
    t.string   "relation",     limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "relationships", ["primary_id"], name: "index_relationships_on_primary_id", using: :btree
  add_index "relationships", ["secondary_id"], name: "index_relationships_on_secondary_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "name",     limit: 255
    t.string "email",    limit: 255
    t.string "provider", limit: 255
    t.string "uid",      limit: 255
  end

  add_foreign_key "device_states", "devices"
  add_foreign_key "devices", "models"
  add_foreign_key "models", "brands"
end
