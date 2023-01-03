class IncidentCollection
  include Enumerable

  def initialize(file_name, important_services)
    @file_name = file_name
    @important_services = important_services
    @incidents = []

    parse
  end

  def parse
    csv = CSV.new(File.read(@file_name), headers: true)
    csv_rows = []
    csv.each do |r|
      @incidents << Incident.new(r)
    end
  end

  def each
    @incidents.each do |i|
      if @important_services.include?(i.service_name)
        yield(i)
      end
    end
  end

  def to_s_by_type
    output = {}
    IncidentType.types.each do |type|
      incidents = select { |i| i.incident_type == type }
      next if incidents.empty? # all incidents in other services

      resolution_seconds = incidents.collect { |i| i.seconds_to_resolve.to_i }.sum / incidents.count 
      resolution_time = Time.at(resolution_seconds).utc.strftime("%H:%M:%S")
      output[incidents.count] = "=====================================================================================
Description: #{type.name.strip}
Incidents: #{incidents.count}
Service Name: #{incidents.collect(&:service_name).uniq}
Average resolution time: #{resolution_time}
---------------------------------------------------------------------
Sample incident:
#{incidents.first.to_s}
---------------------------------------------------------------------"
    end

    output.keys.sort.reverse.collect { |k| output[k] }.compact
  end

  def incidents
    @incidents
  end
end

class Incident
  def initialize(params)
    params.each_pair do |key, value|
      define_singleton_method(key.to_sym) do
        value
      end
    end

    @incident_type = IncidentType.find(description)
  end

  def incident_type
    @incident_type
  end

  def to_s
    contents = []
    contents << description
    contents << service_name
    contents << "Triggered at: #{created_on}"
    resolution_time = Time.at(seconds_to_resolve.to_i).utc.strftime("%H:%M:%S")
    contents << "Time to resolve: #{resolution_time}"
    # contents << "#{@config.host}/incidents/#{row["id"]}"

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
      return new_type
    end

    scores = {}

    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)

    # for each type
    @types.each do |type|
      # fuzzy string match against the type
      scores[type] = jarow.getDistance(name, type.name)
    end
    # look at the best match
    best_type, best_score = scores.sort_by {|k, v| -v }.first

    if best_score > 0.9
      # if it is above the threshold, return that type
      return best_type
    else
      # if it is below the threshold, make a new type
      new_type = new(name)
      @types << new_type
      return new_type
    end
  end

  def self.types
    @types
  end

  def initialize(name)
    @name = name
  end

  def name
    @name
  end
end