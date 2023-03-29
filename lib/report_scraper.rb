require_relative "./config"
require_relative "./incident_collection"
require_relative "./incident_reader"

module ReportScraper
  def self.scrape
    IncidentReader.new.run
  end

  def self.config
    @config ||= Config.new
  end
end
