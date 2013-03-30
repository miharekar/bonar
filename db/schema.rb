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

ActiveRecord::Schema.define(version: 20130330121333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "features", force: true do |t|
    t.string   "title"
    t.integer  "feature_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features_restaurants", id: false, force: true do |t|
    t.integer "feature_id",    null: false
    t.integer "restaurant_id", null: false
  end

  add_index "features_restaurants", ["restaurant_id", "feature_id"], name: "index_features_restaurants_on_restaurant_id_and_feature_id", unique: true

  create_table "restaurants", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "price"
    t.text     "coordinates"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.string   "restaurant_id"
    t.text     "opening"
    t.text     "menu"
    t.text     "telephone"
    t.boolean  "disabled",      default: false
  end

end
