require 'csv'

require_relative "./config.rb"

class IncidentReader
  # lookback_window, days to look back.  0 will look back to midnight today
  def initialize(lookback_window = 2)
    @config = Config.new

    @end_at = CGI.escape(Time.now.strftime("%FT%T"))
    @start_at = CGI.escape((Time.now.to_date - lookback_window).strftime("%FT%T"))

    @time_zone = CGI.escape(Time.now.strftime("%Z"))
  end

  def run
    input_file_name = File.join(File.dirname(__FILE__), "..", "incidents", "raw", "incidents_#{@start_at}_to_#{@end_at}.csv")
    download_incident_list(input_file_name)
    contents = parse_input_file(input_file_name)

    output_file_name = File.join(File.dirname(__FILE__), "..", "incidents", "formatted", "incidents_#{@start_at}_to_#{@end_at}.txt")
    save_output_file(contents, output_file_name)
    print_output_file(contents)
  end

  def parse_input_file(file_name)
    csv = CSV.new(File.read(file_name), headers: true)
    csv_rows = []
    csv.each do |r|
      csv_rows << r.to_h
    end

    # sort in order of longest resolution time, descending
    csv_rows.sort! { |a, b| b["seconds_to_resolve"].to_i <=> a["seconds_to_resolve"].to_i }

    important_services = @config.service_names

    contents = []

    csv_rows.each do |row|
      if important_services.include?(row["service_name"])
        contents << "====================================================================================="
        contents << row["description"]
        contents << row["service_name"]
        contents << "Triggered at: #{row["created_on"]}"
        resolution_time = Time.at(row["seconds_to_resolve"].to_i).utc.strftime("%H:%M:%S")
        contents << "Time to resolve: #{resolution_time}"
        contents << "#{@config.host}/incidents/#{row["id"]}"
      end
    end

    contents
  end

  # todo: convert to html
  def save_output_file(contents, file_name)
    File.open(file_name, 'w') do |file|
      contents.each do |row|
        file.write("#{row}\n")
      end
    end
  end

  def print_output_file(contents)
    contents.each do |row|
      puts row
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

  # note that this is hard coded to west coast time
  def incident_list_url
    "#{@config.host}/api/v1/reports/raw/incidents.csv?since=#{@start_at}&until=#{@end_at}&filters[urgency]=high%2Clow&rollup=daily&time_zone=#{@time_zone}"
  end
end
