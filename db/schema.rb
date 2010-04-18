# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100418150923) do

  create_table "activities", :force => true do |t|
    t.string   "description"
    t.integer  "statement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "statement_id"
    t.text     "description"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "item_type",    :limit => 1
  end

  create_table "politicians", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statements", :force => true do |t|
    t.string   "entity"
    t.string   "position"
    t.string   "event"
    t.date     "event_date"
    t.integer  "total_property",    :default => 0
    t.integer  "total_funds",       :default => 0
    t.integer  "total_insurance",   :default => 0
    t.integer  "total_vehicles",    :default => 0
    t.integer  "total_cash",        :default => 0
    t.integer  "total_liabilities", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "politician_id"
    t.string   "url"
  end

end
