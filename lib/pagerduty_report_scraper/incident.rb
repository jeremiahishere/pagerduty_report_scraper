module PagerdutyReportScraper
  class Incident < ActiveRecord::Base
    belongs_to :scrape

    def to_s
      attributes.inspect
    end
  end
end
