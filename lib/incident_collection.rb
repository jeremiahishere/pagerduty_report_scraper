class IncidentCollection
  include Enumerable

  def initialize(file_name)
    @file_name = file_name
    @important_services = ReportScraper.config.service_names
    @host = ReportScraper.config.host
    @incidents = []

    parse
  end

  def parse
    csv = CSV.new(File.read(@file_name), headers: true)
    csv_rows = []
    csv.each do |r|
      if @important_services.include?(r["service_name"])
        @incidents << Incident.new(r, @host) 
      end
    end

    puts "There are #{@incidents.size} incidents to look at"
  end

  def each
    @incidents.each do |i|
      yield(i)
    end
  end

  def to_s_by_type
    output = []
    IncidentType.types.each do |type|
      incidents = select { |i| i.incident_type == type }

      resolution_seconds = incidents.collect { |i| i.seconds_to_resolve.to_i }.sum / incidents.count 
      resolution_time = Time.at(resolution_seconds).utc.strftime("%H:%M:%S")

      output << {
        incident_count: incidents.count,
        summary: "=====================================================================================
Description: #{type.name.strip}
Incidents: #{incidents.count}
Service Name: #{incidents.collect(&:service_name).uniq}
Average resolution time: #{resolution_time}
---------------------------------------------------------------------
First 10 incidents:
#{incidents.slice(0, 10).collect { |i| "* #{i.url}" }.join("\n")}
---------------------------------------------------------------------
Sample incident:
#{incidents.last.to_s}
---------------------------------------------------------------------"
      }
    end

    output.sort_by { |o| o[:incident_count] }.reverse.collect { |o| o[:summary] }.compact
  end

  def incidents
    @incidents
  end
end

class Incident
  def initialize(params, host)
    params.each_pair do |key, value|
      define_singleton_method(key.to_sym) do
        value
      end
    end

    @incident_type = IncidentType.find(description)
    @host = host
  end

  def incident_type
    @incident_type
  end

  def url
    "https://#{@host}/incidents/#{id}"
  end

  def to_s
    contents = []
    contents << description
    contents << service_name
    contents << "Triggered at: #{created_on}"
    resolution_time = Time.at(seconds_to_resolve.to_i).utc.strftime("%H:%M:%S")
    contents << "Time to resolve: #{resolution_time}"
    contents << "Link: #{url}"

    return contents.join("\n")
  end
end

require "fuzzystringmatch"

class IncidentType
  def self.find(name)
    @types ||= []
    if @types.empty?
      new_type = new(name)
      @types << new_type
      print "|"
      return new_type
    end

    scores = {}

    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)

    # return the first good type
    @types.each do |type|
      score = jarow.getDistance(name, type.name)
      if score > ReportScraper.config.fuzzy_match_threshold
        type.add
        print "."
        return type 
      end
    end

    # if it is below the threshold, make a new type
    new_type = new(name)
    @types << new_type
    print "|"
    return new_type
  end

  def self.types
    @types
  end

  def initialize(name)
    @name = name
    @incidents = 1
  end

  def name
    @name
  end

  def add
    @incidents += 1
  end

  def incident_count
    @incidents
  end
end
