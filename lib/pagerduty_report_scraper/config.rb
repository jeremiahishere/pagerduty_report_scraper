require "yaml"

module PagerdutyReportScraper
  class Config
    def initialize
      @config = YAML.load_file(File.join(File.dirname(__FILE__), "..", "..", "config.yml"))["config"]
    end

    # no trailing slash
    def host
      @config["host"]
    end

    # number of days to look back
    def lookback_window
      @config["lookback_window"].to_i
    end
  end
end
