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

ActiveRecord::Schema.define(version: 20141019214948) do

  create_table "items", force: true do |t|
    t.string  "name"
    t.text    "content"
    t.integer "revision_id"
    t.integer "line_count"
    t.integer "smell_count"
  end

  add_index "items", ["revision_id"], name: "index_items_on_revision_id"

  create_table "projects", force: true do |t|
    t.string "git"
    t.string "name"
    t.string "dir"
  end

  create_table "revisions", force: true do |t|
    t.integer "project_id"
    t.string  "commit_id"
    t.integer "epoch_time"
    t.string  "time"
  end

  add_index "revisions", ["project_id"], name: "index_revisions_on_project_id"

end
