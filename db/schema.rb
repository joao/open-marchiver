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

ActiveRecord::Schema.define(version: 20170523013400) do

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "priority",                 default: 0, null: false
    t.integer  "attempts",                 default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "publication_id"
    t.integer  "number"
    t.datetime "date"
    t.integer  "width"
    t.integer  "height"
    t.integer  "minZoom"
    t.integer  "maxZoom"
    t.boolean  "tiles_generated"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "issue_map_file"
    t.string   "file"
    t.string   "processing_status"
    t.string   "pdf_type"
    t.index ["date"], name: "index_issues_on_date", using: :btree
    t.index ["pdf_type"], name: "index_issues_on_pdf_type", using: :btree
    t.index ["processing_status"], name: "index_issues_on_processing_status", using: :btree
    t.index ["publication_id"], name: "index_issues_on_publication_id", using: :btree
  end

  create_table "page_contents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "page_id"
    t.string   "content_type"
    t.string   "filename"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "file_size"
    t.integer  "user_id"
    t.string   "status"
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "issue_id"
    t.integer  "number"
    t.string   "filename"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "file_size"
    t.text     "text_content", limit: 65535
    t.index ["issue_id"], name: "index_pages_on_issue_id", using: :btree
    t.index ["number"], name: "index_pages_on_number", using: :btree
  end

  create_table "publications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.string   "frequency"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "visible"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "age_range"
    t.string   "gender"
    t.boolean  "suspended"
    t.string   "role"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["provider"], name: "index_users_on_provider", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["suspended"], name: "index_users_on_suspended", using: :btree
    t.index ["uid"], name: "index_users_on_uid", using: :btree
  end


end
