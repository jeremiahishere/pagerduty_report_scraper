module PagerdutyReportScraper
  class UrgentByServiceReport

    attr_reader :scrape, :service_name

    def initialize(scrape, service_name)
      @scrape = scrape
      @service_name = service_name
    end

    def incidents
      scrape.incidents.by_service_name(service_name).urgent
    end

    def report_name(service_name)
      "Urgent Incidents for #{service_name}"
    end

    def generate
      @report_template ||= File.read("../templates/urgent_by_service_report.html.erb")
      rhtml = ERB.new(@report_template)
      rhtml.run(self.get_binding) # self probably not necessary
    end

    def generate_incident(incident)
      @incident_template ||= File.read("../templates/_incident.html.erb")
      rhtml = ERB.new(@incident_template)
      rhtml.run(incident.get_binding)
    end
  end
end
