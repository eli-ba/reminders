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

ActiveRecord::Schema.define(version: 20150411145937) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.integer  "start_time_hour"
    t.integer  "start_time_min"
    t.integer  "end_time_hour"
    t.integer  "end_time_min"
    t.string   "start_date"
    t.string   "end_date"
    t.boolean  "is_repeating",          default: false, null: false
    t.boolean  "confirm_when_finished", default: false, null: false
    t.integer  "user_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.text     "content",     null: false
    t.integer  "time_margin"
    t.integer  "activity_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "reminders", ["activity_id"], name: "index_reminders_on_activity_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "location"
    t.text     "status"
    t.integer  "current_activity_id"
    t.integer  "profile_picture_id"
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "access_token"
    t.datetime "access_token_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "activities", "users"
  add_foreign_key "reminders", "activities"
end
