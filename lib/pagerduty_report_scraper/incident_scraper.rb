require 'csv'
require 'cgi'

require_relative "./config.rb"
require_relative "./incident_collection.rb"

module PagerdutyReportScraper
  class IncidentScraper
    # lookback_window, days to look back.  0 will look back to midnight today
    def initialize(lookback_window)
      @scrape = Scrape.new(
        lookback_window: lookback_window,
        end_at: Time.now
      )

      @config = Config.new
    end

    def run
      download_incident_list(@scrape.filename)

      save_incidents

      binding.pry
      puts "bye"
    end

    def save_incidents
      each_raw_incident do |attributes|
        puts attributes.to_s
        incident = Incident.new(attributes)
        incident.scrape = @scrape
        incident.save!
      end
    end

    def each_raw_incident
      csv = CSV.new(File.read(@scrape.filename), headers: true)
      csv_rows = []
      csv.each do |r|
        r["pagerduty_id"] = r.delete("id").last
        yield r
      end
    end

    # you are required to be logged in to pagerduty on your default browser before running this step
    def download_incident_list(file_name)
      raw_file_name = File.expand_path("~/Downloads/incidents.csv")
      if File.exists?(raw_file_name)
        puts "Deleted old Downloads file #{raw_file_name}"
        FileUtils.rm(raw_file_name)
      end
    
      puts "Request report from #{incident_list_url}"
      `open "#{incident_list_url}"`
      until File.exists?(raw_file_name) do
        puts "Waiting for file to download"
        sleep(1)
      end

      if File.exists?(file_name)
        puts "Deleted old incidents/raw file #{file_name}"
        FileUtils.rm(file_name)
      end

      `mv #{raw_file_name} #{file_name}`
      puts "#{raw_file_name} written to #{file_name}"
    end

    def incident_list_url
      end_at = CGI.escape(@scrape.end_at.strftime("%FT%T"))
      start_at = CGI.escape(@scrape.start_at.strftime("%FT%T"))
      # the pagerduty api doesn't like the edt time zone
      # time_zone = CGI.escape(@scrape.end_at.strftime("%Z"))

      "https://#{@config.host}/api/v1/reports/raw/incidents.csv?since=#{start_at}&until=#{end_at}&filters[urgency]=high%2Clow&rollup=daily" # &time_zone=#{time_zone}"
    end
  end
end
