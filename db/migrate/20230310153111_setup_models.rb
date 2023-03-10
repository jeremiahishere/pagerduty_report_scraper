class Setupmodels < ActiveRecord::Migration[7.0]
  def self.up
    unless ActiveRecord::Base.connection.tables.include?("scrapes")
      create_table :scrapes do |t|
        t.datetime :end_at
        t.integer :lookback_window

        t.timestamps
      end
    end

    unless ActiveRecord::Base.connection.tables.include?("incidents")
      create_table "incidents" do |t|
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

        t.timestamps
      end
    end
  end

  def self.down
    drop_table "incidents"
  end
end
