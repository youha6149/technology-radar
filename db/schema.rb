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

ActiveRecord::Schema[8.0].define(version: 2026_10_25_153422) do
  create_table "jobs", force: :cascade do |t|
    t.integer "raw_document_id", null: false
    t.string "title"
    t.string "company"
    t.string "position"
    t.json "job_types", default: [], null: false
    t.text "description"
    t.integer "salary_min"
    t.integer "salary_max"
    t.json "technologies", default: [], null: false
    t.json "features", default: [], null: false
    t.datetime "extracted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["raw_document_id"], name: "index_jobs_on_raw_document_id", unique: true
  end

  create_table "raw_documents", force: :cascade do |t|
    t.string "source", null: false
    t.string "url", null: false
    t.string "content_type", null: false
    t.text "body", null: false
    t.datetime "fetched_at", null: false
    t.text "parse_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_raw_documents_on_url", unique: true
  end

  create_table "reactions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.integer "verdict", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_reactions_on_job_id", unique: true
  end

  create_table "reasons", force: :cascade do |t|
    t.integer "reaction_id", null: false
    t.string "aspect", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aspect"], name: "index_reasons_on_aspect"
    t.index ["reaction_id"], name: "index_reasons_on_reaction_id"
  end

  add_foreign_key "jobs", "raw_documents"
  add_foreign_key "reactions", "jobs"
  add_foreign_key "reasons", "reactions"
end
