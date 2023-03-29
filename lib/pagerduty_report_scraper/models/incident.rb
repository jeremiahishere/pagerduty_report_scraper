module PagerdutyReportScraper
  class Incident < ActiveRecord::Base
    belongs_to :scrape

    scope :by_service_name, lambda { |name| where(service_name: name) }
    scope :urgent, labmda { where(urgency: "high")
    scope :not_urgent, labmda { where(urgency: "low")

    def to_s
      attributes.inspect
    end
  end
end
