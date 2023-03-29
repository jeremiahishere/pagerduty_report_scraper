module PagerdutyReportScraper
  class IncidentCollection
    include Enumerable

    attr_reader :incidents

    def initialize(scrape)
      @scrape = scrape
      @incidents = scrape.incidents
    end

    def each
      @incidents.each do |i|
        yield(i)
      end
    end

    def by_service
      {}.tap do |output|
        @scrape.services.each do |service_name|
          output[service_name] = @incidents.by_service_name(service_name)
        end
      end
    end

    def urgent_by_service
      {}.tap do |output|
        @scrape.services.each do |service_name|
          output[service_name] = @incidents.by_service_name(service_name).urgent
        end
      end
    end

    def not_urgent_by_service
      {}.tap do |output|
        @scrape.services.each do |service_name|
          output[service_name] = @incidents.by_service_name(service_name).not_urgent
        end
      end
    end

    def urgent_resolution_time_by_service
      buckets = [
        60,
        300,
        600,
        1800,
        3600,
      ]
      {}.tap do |output|
        @scrape.services.each do |service_name|
          output[service_name] = {}
          buckets.each do |bucket|
            output[service_name][bucket] = @incidents.by_service_name(service_name).urgent.where("seconds_to_resolve <= ?", bucket)
          end

          output[service_name]["3600+"] = @incidents.by_service_name(service_name).urgent.where("seconds_to_resolve > ?", 3600)
        end
      end
    end


    def by_week
      # use the lookback window to see how far back to look
      # generate a hash
      # keys: week names
      # values: array of incidents
    end

#        id: 406,
#  scrape_id: 3,
#  pagerduty_id: "Q38V2M61ITSKVU",
#  incident_number: "96830",
#  description: "prod-doximity-10-0-1-133.dox.box/cinc-client : CheckProcess CRITICAL: Found 0 matching processes; cmd /cinc-client/\n",
#  service_id: "POQT69N",
#  service_name: "SRE Not Urgent Service",
#  escalation_policy_id: "P5AGSRY",
#  escalation_policy_name: "SRE Not Urgent Escalation Policy",
#  created_on: "2023-02-26T00:10:04+00:00",
#  resolved_on: "2023-02-26T00:34:06+00:00",
#  seconds_to_first_ack: nil,
#  seconds_to_resolve: "1442",
#  auto_resolved: "0",
#  escalation_count: "0",
#  auto_escalation_count: "0",
#  acknowledge_count: "0",
#  assignment_count: "1",
#  acknowledged_by_user_ids: nil,
#  acknowledged_by_user_names: nil,
#  assigned_to_user_ids: "PW28787",
#  assigned_to_user_names: "Josh Lauer",
#  resolved_by_user_id: nil,
#  resolved_by_user_name: nil,
#  urgency: "low",
#  created_at: 2023-03-28 17:32:29.593898 UTC,
#  updated_at: 2023-03-28 17:32:29.593898 UTC>


      # possible groupings:
      # by week
      # by day
      # by service_id/service_name
      # by resolution length/seconds to resolve
      # by assigned user, acknowledges user, resolved by user
      # by urgency
      # by description with fuzziness
      #

  #   def initialize(file_name, important_services, host)
  #     @file_name = file_name
  #     @important_services = important_services
  #     @host = host
  #     @incidents = []
  #
  #     parse
  #   end
  #
  #   def parse
  #     csv = CSV.new(File.read(@file_name), headers: true)
  #     csv_rows = []
  #     csv.each do |r|
  #       r["pagerduty_id"] = r.delete("id").last
  #       @incidents << Incident.new(r)
  #     end
  #   end
  #
  #   def each
  #     @incidents.each do |i|
  #       if @important_services.include?(i.service_name)
  #         yield(i)
  #       end
  #     end
  #   end
  #
  #   def to_s_by_type
  #     output = {}
  #     IncidentType.types.each do |type|
  #       incidents = select { |i| i.incident_type == type }
  #       next if incidents.empty? # all incidents in other services
  #
  #       resolution_seconds = incidents.collect { |i| i.seconds_to_resolve.to_i }.sum / incidents.count 
  #       resolution_time = Time.at(resolution_seconds).utc.strftime("%H:%M:%S")
  #       output[incidents.count] = "=====================================================================================
  # Description: #{type.name.strip}
  # Incidents: #{incidents.count}
  # Service Name: #{incidents.collect(&:service_name).uniq}
  # Average resolution time: #{resolution_time}
  # ---------------------------------------------------------------------
  # First 10 incidents:
  # #{incidents.slice(0, 10).collect { |i| "* #{i.url}" }.join("\n")}
  # ---------------------------------------------------------------------
  # Sample incident:
  # #{incidents.last.to_s}
  # ---------------------------------------------------------------------"
  #     end
  #
  #     output.keys.sort.reverse.collect { |k| output[k] }.compact
  #   end
  #
  #   def incidents
  #     @incidents
  #   end
  end
end

# class Incident
#   def initialize(params, host)
#     params.each_pair do |key, value|
#       define_singleton_method(key.to_sym) do
#         value
#       end
#     end
#
#     @incident_type = IncidentType.find(description)
#     @host = host
#   end
#
#   def incident_type
#     @incident_type
#   end
#
#   def url
#     "https://#{@host}/incidents/#{id}"
#   end
#
#   def to_s
#     contents = []
#     contents << description
#     contents << service_name
#     contents << "Triggered at: #{created_on}"
#     resolution_time = Time.at(seconds_to_resolve.to_i).utc.strftime("%H:%M:%S")
#     contents << "Time to resolve: #{resolution_time}"
#     contents << "Link: #{url}"
#
#     return contents.join("\n")
#   end
# end
#
# require "fuzzystringmatch"
#
# class IncidentType
#   def self.find(name)
#     @types ||= []
#     if @types.empty?
#       new_type = new(name)
#       @types << new_type
#       return new_type
#     end
#
#     scores = {}
#
#     jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
#
#     # for each type
#     @types.each do |type|
#       # fuzzy string match against the type
#       scores[type] = jarow.getDistance(name, type.name)
#     end
#     # look at the best match
#     best_type, best_score = scores.sort_by {|k, v| -v }.first
#
#     if best_score > fuzzy_match_threshold
#       # if it is above the threshold, return that type
#       return best_type
#     else
#       # if it is below the threshold, make a new type
#       new_type = new(name)
#       @types << new_type
#       return new_type
#     end
#   end
#   
#   def self.fuzzy_match_threshold
#     # separate types per node internal ip
#     # 0.99
#
#     # some alerts are grouped ignoring internal ip/db name but some are separate
#     # this threshold isn't really useful
#     # 0.95
#
#     # grouped types per alert, ignoring internal ip or database name
#     0.9
#   end
#
#   def self.types
#     @types
#   end
#
#   def initialize(name)
#     @name = name
#   end
#
#   def name
#     @name
#   end
# end
