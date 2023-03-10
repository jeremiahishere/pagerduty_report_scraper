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

ActiveRecord::Schema[7.0].define(version: 0) do
  create_table "incidents", force: :cascade do |t|
    t.integer "scrape_id"
    t.string "pagerduty_id"
    t.string "incident_number"
    t.string "description"
    t.string "service_id"
    t.string "service_name"
    t.string "escalation_policy_id"
    t.string "escalation_policy_name"
    t.string "created_on"
    t.string "resolved_on"
    t.string "seconds_to_first_ack"
    t.string "seconds_to_resolve"
    t.string "auto_resolved"
    t.string "escalation_count"
    t.string "auto_escalation_count"
    t.string "acknowledge_count"
    t.string "assignment_count"
    t.string "acknowledged_by_user_ids"
    t.string "acknowledged_by_user_names"
    t.string "assigned_to_user_ids"
    t.string "assigned_to_user_names"
    t.string "resolved_by_user_id"
    t.string "resolved_by_user_name"
    t.string "urgency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrapes", force: :cascade do |t|
    t.datetime "end_at"
    t.integer "lookback_window"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
