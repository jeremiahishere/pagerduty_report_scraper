require "active_record"

db_config = YAML::load(File.open('config/database.yml'))

ActiveRecord::Base.establish_connection(db_config["database"])

require_relative "./pagerduty_report_scraper/config"

require_relative "./pagerduty_report_scraper/models/incident"
require_relative "./pagerduty_report_scraper/models/scrape"

# require_relative "./pagerduty_report_scraper/incident_collection"
require_relative "./pagerduty_report_scraper/incident_scraper"

module PagerdutyReportScraper
  def self.scrape
    IncidentScraper.new(Config.new.lookback_window).run
  end

  def self.shell
    binding.pry
  end

  def self.config
    @config ||= Config.new
  end
end
