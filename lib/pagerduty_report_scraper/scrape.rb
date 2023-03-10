module PagerdutyReportScraper
  class Scrape < ActiveRecord::Base
    has_many :incidents

    def start_at
      end_at.to_date - lookback_window
    end

    def filename
      File.join(File.dirname(__FILE__), "..", "..", "incidents", "raw", "scrape_#{id}.csv")
    end

    def incident_list_url
    end
  end
end
